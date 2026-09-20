from firebase_functions import firestore_fn
from firebase_functions.options import set_global_options
from firebase_admin import initialize_app, firestore, messaging


# Limit the maximum number of Cloud Function instances.
set_global_options(max_instances=10)


# Initialize Firebase Admin SDK.
initialize_app()


def _get_notification_recipients(
    db,
    elder_id: str,
):
    """
    Finds caregivers and emergency contacts who should receive alerts.

    Current expected Firestore structure:

    users/{userId}
        role: "caregiver" OR "emergency_contact"
        fcmToken: "device FCM token"

    Current behavior:
    - Sends to all caregivers.
    - Sends to all emergency contacts.
    - Avoids duplicate FCM tokens.

    The elder_id is currently accepted so that this function can later
    be restricted to caregivers/emergency contacts connected to a
    particular elder.
    """

    del elder_id  # Reserved for elder-specific filtering later.

    recipients = []
    token_set = set()

    recipient_roles = [
        "caregiver",
        "emergency_contact",
    ]

    for role in recipient_roles:
        try:
            users = (
                db.collection("users")
                .where("role", "==", role)
                .stream()
            )

            for user_document in users:
                user_data = user_document.to_dict()

                fcm_token = user_data.get("fcmToken")

                if not fcm_token:
                    continue

                if not isinstance(fcm_token, str):
                    continue

                fcm_token = fcm_token.strip()

                if not fcm_token:
                    continue

                if fcm_token in token_set:
                    continue

                token_set.add(fcm_token)

                recipients.append(
                    {
                        "userId": user_document.id,
                        "role": role,
                        "fcmToken": fcm_token,
                    }
                )

        except Exception as error:
            print(
                f"Could not load recipients with role "
                f"{role}: {error}"
            )

    return recipients


def _send_notification_to_recipients(
    recipients,
    title: str,
    body: str,
):
    """
    Sends one push notification to each recipient.

    A failed or invalid token will not stop the remaining
    recipients from receiving the notification.
    """

    successful_count = 0
    failed_count = 0

    for recipient in recipients:
        fcm_token = recipient.get("fcmToken")

        if not fcm_token:
            continue

        message = messaging.Message(
            notification=messaging.Notification(
                title=title,
                body=body,
            ),
            token=fcm_token,
        )

        try:
            response = messaging.send(message)

            successful_count += 1

            print(
                f"Notification sent successfully to "
                f"{recipient.get('userId')}. "
                f"Message ID: {response}"
            )

        except Exception as error:
            failed_count += 1

            print(
                f"Notification failed for "
                f"{recipient.get('userId')}: {error}"
            )

    print(
        f"Notification result: "
        f"{successful_count} successful, "
        f"{failed_count} failed."
    )


def _get_location_text(
    latitude,
    longitude,
):
    """
    Creates a readable location string.
    """

    return (
        f"Latitude: {latitude}, "
        f"Longitude: {longitude}"
    )


# ============================================================
# SOS ALERT FUNCTION
# ============================================================

@firestore_fn.on_document_created(
    document="sosAlerts/{sosId}"
)
def on_sos_created(
    event: firestore_fn.Event[
        firestore_fn.DocumentSnapshot
    ],
):
    """
    Triggered whenever a new SOS alert is created.

    Expected Firestore document:

    sosAlerts/{sosId}
        userId
        latitude
        longitude
        timestamp
        status
    """

    sos = event.data

    if sos is None:
        print("SOS document data is missing.")
        return

    sos_data = sos.to_dict()

    if sos_data is None:
        print(
            "SOS document could not be converted to a map."
        )
        return

    user_id = sos_data.get(
        "userId",
        "Unknown elder",
    )

    latitude = sos_data.get(
        "latitude",
        "Unknown",
    )

    longitude = sos_data.get(
        "longitude",
        "Unknown",
    )

    status = sos_data.get(
        "status",
        "ACTIVE",
    )

    # Ignore invalid or cancelled SOS records.
    if status == "CANCELLED":
        print(
            f"SOS {sos.id} is already cancelled. "
            f"No notification sent."
        )
        return

    db = firestore.client()

    recipients = _get_notification_recipients(
        db=db,
        elder_id=user_id,
    )

    if not recipients:
        print(
            "No caregivers or emergency contacts with "
            "valid FCM tokens were found."
        )
        return

    location_text = _get_location_text(
        latitude=latitude,
        longitude=longitude,
    )

    notification_title = "🚨 Emergency SOS"

    notification_body = (
        f"Emergency SOS received from elder {user_id}. "
        f"{location_text}"
    )

    _send_notification_to_recipients(
        recipients=recipients,
        title=notification_title,
        body=notification_body,
    )


# ============================================================
# SAFE-ZONE VIOLATION FUNCTION
# ============================================================

@firestore_fn.on_document_created(
    document="safeZoneViolations/{violationId}"
)
def on_safe_zone_violation_created(
    event: firestore_fn.Event[
        firestore_fn.DocumentSnapshot
    ],
):
    """
    Triggered whenever a safe-zone violation document is created.

    Expected Firestore document:

    safeZoneViolations/{violationId}
        elderId
        safeZoneId
        safeZoneName
        latitude
        longitude
        timestamp
        status
    """

    violation = event.data

    if violation is None:
        print("Safe-zone violation data is missing.")
        return

    violation_data = violation.to_dict()

    if violation_data is None:
        print(
            "Safe-zone violation could not be converted "
            "to a map."
        )
        return

    elder_id = violation_data.get(
        "elderId",
        "Unknown elder",
    )

    safe_zone_id = violation_data.get(
        "safeZoneId",
        "Unknown safe zone",
    )

    safe_zone_name = violation_data.get(
        "safeZoneName",
        "Assigned safe zone",
    )

    latitude = violation_data.get(
        "latitude",
        "Unknown",
    )

    longitude = violation_data.get(
        "longitude",
        "Unknown",
    )

    status = violation_data.get(
        "status",
        "OUTSIDE",
    )

    # Keep the safe-zone ID available for future
    # elder-specific notification filtering.
    del safe_zone_id

    # Only notify for an actual outside-zone event.
    if status != "OUTSIDE":
        print(
            f"Safe-zone violation {violation.id} has status "
            f"{status}. No notification sent."
        )
        return

    db = firestore.client()

    recipients = _get_notification_recipients(
        db=db,
        elder_id=elder_id,
    )

    if not recipients:
        print(
            "No caregivers or emergency contacts with "
            "valid FCM tokens were found."
        )
        return

    location_text = _get_location_text(
        latitude=latitude,
        longitude=longitude,
    )

    notification_title = "⚠️ Safe-Zone Alert"

    notification_body = (
        f"Elder {elder_id} has left the safe zone "
        f"'{safe_zone_name}'. "
        f"{location_text}"
    )

    _send_notification_to_recipients(
        recipients=recipients,
        title=notification_title,
        body=notification_body,
    )