from datetime import datetime, timezone, timedelta

import firebase_admin
from firebase_admin import firestore, messaging
from firebase_functions import scheduler_fn
from firebase_functions.options import set_global_options


# Initialize Firebase Admin SDK
firebase_admin.initialize_app()

db = firestore.client()

set_global_options(max_instances=10)


def parse_scheduled_time(value):
    """Convert the stored ISO string into a timezone-aware datetime."""
    if not value:
        return None

    try:
        parsed = datetime.fromisoformat(value.replace("Z", "+00:00"))

        if parsed.tzinfo is None:
            parsed = parsed.replace(tzinfo=timezone.utc)

        return parsed
    except (ValueError, TypeError):
        return None


def get_user_token(user_id):
    """Get an FCM token from users/{user_id}."""
    if not user_id:
        return None

    user_doc = db.collection("users").document(user_id).get()

    if not user_doc.exists:
        return None

    data = user_doc.to_dict() or {}

    token = data.get("fcmToken")

    if isinstance(token, str) and token:
        return token

    return None


def send_notification(
    token,
    title,
    body,
    notification_type,
    elder_id,
    reminder_id,
):
    """Send one FCM notification."""
    if not token:
        return False

    message = messaging.Message(
        notification=messaging.Notification(
            title=title,
            body=body,
        ),
        data={
            "type": notification_type,
            "elderId": elder_id,
            "reminderId": reminder_id,
        },
        token=token,
    )

    try:
        messaging.send(message)
        return True
    except Exception:
        return False


def create_caregiver_alert(
    elder_id,
    reminder_id,
):
    """Create a caregiver alert in Firestore."""
    alerts_ref = (
        db.collection("elders")
        .document(elder_id)
        .collection("alerts")
    )

    alerts_ref.add(
        {
            "title": "Missed Check-in",
            "message": (
                "The elder has not completed the scheduled "
                "check-in."
            ),
            "date": datetime.now(timezone.utc).isoformat(),
            "type": "CHECK_IN_MISSED",
            "reminderId": reminder_id,
        }
    )


def get_caregiver_tokens(elder_id):
    """Find caregiver FCM tokens linked to the elder."""
    tokens = []

    # First try the elder document.
    elder_doc = (
        db.collection("elders")
        .document(elder_id)
        .get()
    )

    if elder_doc.exists:
        elder_data = elder_doc.to_dict() or {}

        caregiver_id = elder_data.get("caregiverId")

        if caregiver_id:
            token = get_user_token(caregiver_id)

            if token:
                tokens.append(token)

    # Also support caregiver users that contain elderId.
    caregiver_query = (
        db.collection("users")
        .where("role", "==", "caregiver")
        .where("elderId", "==", elder_id)
        .stream()
    )

    for caregiver_doc in caregiver_query:
        data = caregiver_doc.to_dict() or {}
        token = data.get("fcmToken")

        if isinstance(token, str) and token:
            tokens.append(token)

    return list(set(tokens))


def send_caregiver_notifications(
    elder_id,
    reminder_id,
):
    """Notify all linked caregivers."""
    tokens = get_caregiver_tokens(elder_id)

    if not tokens:
        return

    for token in tokens:
        send_notification(
            token=token,
            title="Missed Check-in",
            body=(
                "The elder has not completed "
                "the scheduled check-in."
            ),
            notification_type="CHECK_IN_MISSED",
            elder_id=elder_id,
            reminder_id=reminder_id,
        )


def process_reminder(elder_id, reminder_id, reminder_data):
    """Process one pending reminder."""
    status = reminder_data.get("status", "PENDING")

    if status != "PENDING":
        return

    scheduled_time = parse_scheduled_time(
        reminder_data.get("scheduledTime")
    )

    if scheduled_time is None:
        return

    now = datetime.now(timezone.utc)

    elapsed = now - scheduled_time

    # Ignore reminders scheduled in the future.
    if elapsed.total_seconds() < 0:
        return

    first_sent = reminder_data.get(
        "firstReminderSent",
        False,
    )

    second_sent = reminder_data.get(
        "secondReminderSent",
        False,
    )

    caregiver_notified = reminder_data.get(
        "caregiverNotified",
        False,
    )

    # ---------------------------------------------------------
    # FIRST REMINDER
    # Scheduled time → first notification
    # ---------------------------------------------------------

    if not first_sent:
        token = get_user_token(elder_id)

        sent = send_notification(
            token=token,
            title="Daily Check-in",
            body="Please complete your daily check-in.",
            notification_type="FIRST_CHECK_IN_REMINDER",
            elder_id=elder_id,
            reminder_id=reminder_id,
        )

        if sent:
            reminder_ref = (
                db.collection("elders")
                .document(elder_id)
                .collection("checkInReminders")
                .document(reminder_id)
            )

            reminder_ref.update(
                {
                    "firstReminderSent": True,
                }
            )

        return

    # ---------------------------------------------------------
    # SECOND REMINDER
    # Scheduled time + 15 minutes
    # ---------------------------------------------------------

    if (
        elapsed >= timedelta(minutes=15)
        and not second_sent
    ):
        token = get_user_token(elder_id)

        sent = send_notification(
            token=token,
            title="Check-in Reminder",
            body=(
                "You have not completed your check-in. "
                "Please respond now."
            ),
            notification_type="SECOND_CHECK_IN_REMINDER",
            elder_id=elder_id,
            reminder_id=reminder_id,
        )

        if sent:
            reminder_ref = (
                db.collection("elders")
                .document(elder_id)
                .collection("checkInReminders")
                .document(reminder_id)
            )

            reminder_ref.update(
                {
                    "secondReminderSent": True,
                }
            )

        return

    # ---------------------------------------------------------
    # CAREGIVER NOTIFICATION + MISSED
    # Scheduled time + 30 minutes
    # ---------------------------------------------------------

    if (
        elapsed >= timedelta(minutes=30)
        and not caregiver_notified
    ):
        send_caregiver_notifications(
            elder_id=elder_id,
            reminder_id=reminder_id,
        )

        create_caregiver_alert(
            elder_id=elder_id,
            reminder_id=reminder_id,
        )

        reminder_ref = (
            db.collection("elders")
            .document(elder_id)
            .collection("checkInReminders")
            .document(reminder_id)
        )

        reminder_ref.update(
            {
                "caregiverNotified": True,
                "status": "MISSED",
            }
        )


@scheduler_fn.on_schedule(
    schedule="every 1 minutes",
    timezone="Asia/Kolkata",
)
def process_check_in_reminders(event):
    """Process pending check-in reminders every minute."""

    elders = db.collection("elders").stream()

    for elder_doc in elders:
        elder_id = elder_doc.id

        reminders = (
            db.collection("elders")
            .document(elder_id)
            .collection("checkInReminders")
            .where("status", "==", "PENDING")
            .stream()
        )

        for reminder_doc in reminders:
            reminder_data = reminder_doc.to_dict() or {}

            process_reminder(
                elder_id=elder_id,
                reminder_id=reminder_doc.id,
                reminder_data=reminder_data,
            )