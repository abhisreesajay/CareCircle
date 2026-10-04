from firebase_functions import firestore_fn, scheduler_fn
from datetime import datetime, timedelta
from zoneinfo import ZoneInfo
from firebase_functions.options import set_global_options
from firebase_admin import initialize_app, firestore, messaging


# ============================================================
# FIREBASE INITIALIZATION
# ============================================================

initialize_app()

set_global_options(
    max_instances=10,
)


# ============================================================
# GET NOTIFICATION RECIPIENTS
# ============================================================

def _get_notification_recipients(
    db,
    elder_id: str,
):
    """
    Finds caregivers connected to the specific elder.

    Firestore structure:

    users/{userId}
        role: "caregiver"
        linkedElders: [
            "elderUid"
        ]
        fcmTokens: [
            "device-token-1",
            "device-token-2"
        ]

    Emergency contacts can also have FCM tokens, but they
    are not necessarily registered CareCircle users.
    Therefore this function currently sends to linked
    caregivers only.
    """

    recipients = []
    token_set = set()

    try:
        caregivers = (
            db.collection("users")
            .where("role", "==", "caregiver")
            .stream()
        )

        for user_document in caregivers:
            user_data = user_document.to_dict()

            if not user_data:
                continue

            linked_elders = user_data.get(
                "linkedElders",
                [],
            )

            if not isinstance(linked_elders, list):
                continue

            if elder_id not in linked_elders:
                continue

            fcm_tokens = user_data.get(
                "fcmTokens",
                [],
            )

            # Backward compatibility:
            # support the old single-token field too.
            old_token = user_data.get(
                "fcmToken",
            )

            if old_token:
                if isinstance(old_token, str):
                    fcm_tokens = list(fcm_tokens)
                    fcm_tokens.append(old_token)

            if not isinstance(fcm_tokens, list):
                continue

            for token in fcm_tokens:

                if not isinstance(token, str):
                    continue

                token = token.strip()

                if not token:
                    continue

                if token in token_set:
                    continue

                token_set.add(token)

                recipients.append(
                    {
                        "userId": user_document.id,
                        "role": "caregiver",
                        "fcmToken": token,
                    }
                )

    except Exception as error:
        print(
            "Could not load caregiver recipients: "
            f"{error}"
        )

    return recipients


# ============================================================
# SEND NOTIFICATIONS
# ============================================================

def _send_notification_to_recipients(
    recipients,
    title: str,
    body: str,
):
    """
    Sends an FCM notification to every valid recipient.

    A failure for one token does not stop notifications
    from being sent to the remaining recipients.
    """

    successful_count = 0
    failed_count = 0

    for recipient in recipients:

        fcm_token = recipient.get(
            "fcmToken",
        )

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
            response = messaging.send(
                message,
            )

            successful_count += 1

            print(
                "Notification sent successfully to "
                f"{recipient.get('userId')}. "
                f"Message ID: {response}"
            )

        except Exception as error:

            failed_count += 1

            print(
                "Notification failed for "
                f"{recipient.get('userId')}: "
                f"{error}"
            )

    print(
        "Notification result: "
        f"{successful_count} successful, "
        f"{failed_count} failed."
    )


# ============================================================
# LOCATION TEXT
# ============================================================

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

    Firestore:

    sosAlerts/{sosId}

        userId
        latitude
        longitude
        timestamp
        status
    """

    sos = event.data

    if sos is None:
        print(
            "SOS document data is missing."
        )
        return

    sos_data = sos.to_dict()

    if sos_data is None:
        print(
            "SOS document could not be converted "
            "to a map."
        )
        return

    user_id = sos_data.get(
        "userId",
    )

    if not user_id:
        print(
            "SOS does not contain a userId."
        )
        return

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

    # --------------------------------------------------------
    # Ignore cancelled SOS records
    # --------------------------------------------------------

    if status == "CANCELLED":
        print(
            f"SOS {sos.id} is already cancelled. "
            "No notification sent."
        )
        return

    # --------------------------------------------------------
    # Get Firestore
    # --------------------------------------------------------

    db = firestore.client()

    # --------------------------------------------------------
    # Find linked caregivers
    # --------------------------------------------------------

    recipients = _get_notification_recipients(
        db=db,
        elder_id=user_id,
    )

    if not recipients:
        print(
            "No linked caregivers with valid FCM "
            "tokens were found."
        )
        return

    # --------------------------------------------------------
    # Build notification
    # --------------------------------------------------------

    location_text = _get_location_text(
        latitude=latitude,
        longitude=longitude,
    )

    notification_title = "Emergency SOS"

    notification_body = (
        f"Emergency SOS received from elder "
        f"{user_id}. "
        f"{location_text}"
    )

    # --------------------------------------------------------
    # Send
    # --------------------------------------------------------

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
    Triggered whenever a safe-zone violation document
    is created.

    Firestore:

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
        print(
            "Safe-zone violation data is missing."
        )
        return

    violation_data = violation.to_dict()

    if violation_data is None:
        print(
            "Safe-zone violation could not be "
            "converted to a map."
        )
        return

    elder_id = violation_data.get(
        "elderId",
    )

    if not elder_id:
        print(
            "Safe-zone violation does not contain "
            "an elderId."
        )
        return

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

    # --------------------------------------------------------
    # Only notify for an actual outside-zone event
    # --------------------------------------------------------

    if status != "OUTSIDE":
        print(
            f"Safe-zone violation {violation.id} "
            f"has status {status}. "
            "No notification sent."
        )
        return

    # --------------------------------------------------------
    # Get Firestore
    # --------------------------------------------------------

    db = firestore.client()

    recipients = _get_notification_recipients(
        db=db,
        elder_id=elder_id,
    )

    if not recipients:
        print(
            "No linked caregivers with valid FCM "
            "tokens were found."
        )
        return

    # --------------------------------------------------------
    # Build notification
    # --------------------------------------------------------

    location_text = _get_location_text(
        latitude=latitude,
        longitude=longitude,
    )

    notification_title = "Safe-Zone Alert"

    notification_body = (
        f"Elder {elder_id} has left the safe zone "
        f"'{safe_zone_name}'. "
        f"{location_text}"
    )

    # --------------------------------------------------------
    # Send
    # --------------------------------------------------------

    _send_notification_to_recipients(
        recipients=recipients,
        title=notification_title,
        body=notification_body,
    )


# ============================================================
# CHECK-IN REMINDER SCHEDULER
# ============================================================

@scheduler_fn.on_schedule(
    schedule="*/5 * * * *",
    timezone="Asia/Kolkata",
)
def process_checkin_reminders(
    event: scheduler_fn.ScheduledEvent,
) -> None:
    from checkin_scheduler import process_checkins

    process_checkins()