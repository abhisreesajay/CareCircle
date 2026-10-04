import firebase_admin
from firebase_admin import firestore, messaging
from datetime import datetime, timedelta
from zoneinfo import ZoneInfo


db = firestore.client()

IST = ZoneInfo("Asia/Kolkata")


CHECK_IN_TIMES = [
    ("10:00 AM", 10, 0),
    ("2:00 PM", 14, 0),
    ("9:00 PM", 21, 0),
]


def get_user_fcm_tokens(user_id):

    document = (
        db.collection("users")
        .document(user_id)
        .get()
    )

    if not document.exists:
        return []

    data = document.to_dict()

    if not data:
        return []

    tokens = data.get("fcmTokens", [])

    if not isinstance(tokens, list):
        tokens = []

    old_token = data.get("fcmToken")

    if isinstance(old_token, str):
        tokens.append(old_token)

    result = []
    token_set = set()

    for token in tokens:

        if not isinstance(token, str):
            continue

        token = token.strip()

        if not token:
            continue

        if token in token_set:
            continue

        token_set.add(token)
        result.append(token)

    return result


def get_caregiver_fcm_tokens(elder_id):

    recipients = []
    token_set = set()

    caregivers = (
        db.collection("users")
        .where("role", "==", "caregiver")
        .stream()
    )

    for user_document in caregivers:

        data = user_document.to_dict()

        if not data:
            continue

        linked_elders = data.get(
            "linkedElders",
            []
        )

        if not isinstance(linked_elders, list):
            continue

        if elder_id not in linked_elders:
            continue

        tokens = data.get(
            "fcmTokens",
            []
        )

        if not isinstance(tokens, list):
            tokens = []

        old_token = data.get("fcmToken")

        if isinstance(old_token, str):
            tokens.append(old_token)

        for token in tokens:

            if not isinstance(token, str):
                continue

            token = token.strip()

            if not token:
                continue

            if token in token_set:
                continue

            token_set.add(token)
            recipients.append(token)

    return recipients



def send_fcm_to_tokens(tokens, title, body):
    if not tokens:
        print("No FCM tokens found. Notification not sent.")
        return 0

    success = 0

    for token in tokens:
        try:
            message = messaging.Message(
                notification=messaging.Notification(
                    title=title,
                    body=body,
                ),
                android=messaging.AndroidConfig(
                    priority="high"
                ),
                token=token,
            )

            response = messaging.send(message)

            print(f"FCM sent successfully: {response}")
            success += 1

        except Exception as error:
            print(f"FCM failed for one token: {error}")

    print(
        f"Notification result: {success}/{len(tokens)} "
        "device(s) received an accepted FCM send."
    )

    return success


def send_elder_notification(elder_id, title, body):
    tokens = get_user_fcm_tokens(elder_id)

    print(
        f"Elder {elder_id}: {len(tokens)} FCM device(s)"
    )

    if not tokens:
        print("Elder notification skipped: no registered tokens.")
        return False

    successful_sends = send_fcm_to_tokens(
        tokens,
        title,
        body,
    )

    return successful_sends > 0


def send_caregiver_notification(elder_id, title, body):
    tokens = get_caregiver_fcm_tokens(elder_id)

    print(
        f"Caregiver notification: {len(tokens)} device(s)"
    )

    if not tokens:
        print("Caregiver notification skipped: no registered tokens.")
        return False

    successful_sends = send_fcm_to_tokens(
        tokens,
        title,
        body,
    )

    return successful_sends > 0

def get_scheduled_datetime(
    now,
    hour,
    minute
):

    return datetime(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
        tzinfo=IST,
    )



def create_daily_reminders(now):
    today_string = now.strftime("%Y-%m-%d")

    elders = (
        db.collection("users")
        .where("role", "==", "elder")
        .stream()
    )

    for elder_document in elders:
        elder_id = elder_document.id

        for time_text, hour, minute in CHECK_IN_TIMES:
            reminder_id = (
                f"{today_string}_{hour:02d}-{minute:02d}"
            )

            elder_ref = (
                db.collection("elders")
                .document(elder_id)
            )

            reminder_ref = (
                elder_ref
                .collection("checkInReminders")
                .document(reminder_id)
            )

            history_ref = (
                elder_ref
                .collection("checkInHistory")
                .document(reminder_id)
            )

            # Preserve an existing reminder and its notification flags.
            if reminder_ref.get().exists:
                continue

            # Check whether this exact scheduled slot was completed
            # before its reminder document was created.
            history_snapshot = history_ref.get()

            history_data = (
                history_snapshot.to_dict() or {}
            )

            history_status = str(
                history_data.get("status", "")
            ).upper()

            if history_snapshot.exists and history_status in {
                "COMPLETED",
                "HELP_REQUESTED",
            }:
                reminder_ref.set({
                    "elderId": elder_id,
                    "scheduledTime": time_text,
                    "scheduledDate": today_string,
                    "scheduledAt": get_scheduled_datetime(
                        now, hour, minute
                    ),
                    "status": "COMPLETED",
                    "elderNotified": False,
                    "firstReminderSent": False,
                    "secondReminderSent": False,
                    "caregiverNotified": False,
                    "completedAt": firestore.SERVER_TIMESTAMP,
                    "checkInId": history_snapshot.id,
                    "createdAt": firestore.SERVER_TIMESTAMP,
                })

                print(
                    f"Created completed reminder: "
                    f"{elder_id} - {time_text}"
                )
                continue

            scheduled_at = get_scheduled_datetime(
                now, hour, minute
            )

            reminder_ref.set({
                "elderId": elder_id,
                "scheduledTime": time_text,
                "scheduledDate": today_string,
                "scheduledAt": scheduled_at,
                "status": "PENDING",
                "elderNotified": False,
                "firstReminderSent": False,
                "secondReminderSent": False,
                "caregiverNotified": False,
                "createdAt": firestore.SERVER_TIMESTAMP,
            })

            print(
                f"Created: {elder_id} - {time_text}"
            )

def process_reminder(
    reminder,
    now
):
    data = reminder.to_dict()

    if not data:
        return

    elder_id = data.get("elderId")
    scheduled_at = data.get("scheduledAt")
    scheduled_date = data.get("scheduledDate")
    status = data.get("status", "PENDING")

    if not elder_id or not scheduled_at or not scheduled_date:
        print(
            f"Reminder {reminder.id} is missing required fields."
        )
        return

    
    # Completed reminders need no further processing.
    # MISSED reminders must remain eligible for notification retries
    # if the missed-check-in notification was not successfully sent.
    if status == "COMPLETED":
        return

    if status == "MISSED" and data.get("secondReminderSent", False):
        return

    # --------------------------------------------------------
    # Check whether a check-in has already been recorded
    # for this scheduled date.
    # --------------------------------------------------------

    
    # Match this reminder to its specific check-in history record.
    # Flutter uses the same date-and-slot ID for both documents.
    history_ref = (
        db.collection("elders")
        .document(elder_id)
        .collection("checkInHistory")
        .document(reminder.id)
    )

    history_record = history_ref.get()

    if history_record.exists:
        history_data = history_record.to_dict() or {}
        history_status = str(
            history_data.get("status", "")
        ).upper()

        if history_status in {"COMPLETED", "HELP_REQUESTED"}:
            reminder.reference.update({
                "status": "COMPLETED",
                "completedAt": firestore.SERVER_TIMESTAMP,
                "checkInId": history_record.id,
            })

            print(
                f"Matching check-in found for elder {elder_id}: "
                f"{reminder.id}. Reminder completed."
            )
            return

    # --------------------------------------------------------
    # Normalize scheduled time to India time.
    # --------------------------------------------------------

    if scheduled_at.tzinfo is None:
        scheduled_at = scheduled_at.replace(tzinfo=IST)
    else:
        scheduled_at = scheduled_at.astimezone(IST)

    now = now.astimezone(IST)
    elapsed = now - scheduled_at

    if elapsed.total_seconds() < 0:
        return

    # --------------------------------------------------------
    # 0–15 minutes: notify the elder.
    # --------------------------------------------------------

    if elapsed < timedelta(minutes=15):
        if not data.get("elderNotified", False):
            print(
                f"Sending check-in notification to elder {elder_id}."
            )

            sent = send_elder_notification(
                elder_id,
                "CareCircle Daily Check-in",
                "It is time for your daily check-in. "
                "Please complete your check-in.",
            )

            if sent:
                reminder.reference.update({
                    "elderNotified": True,
                })

        return

    # --------------------------------------------------------
    # 15–30 minutes: notify the caregiver once.
    # --------------------------------------------------------

    if elapsed < timedelta(minutes=30):
        if not data.get("firstReminderSent", False):
            print(
                f"Sending 15-minute reminder for elder {elder_id}."
            )

            sent = send_caregiver_notification(
                elder_id,
                "CareCircle Check-in Reminder",
                "The elder has not completed "
                "the scheduled check-in yet.",
            )

            if sent:
                reminder.reference.update({
                    "firstReminderSent": True,
                    "status": "FIRST_REMINDER_SENT",
                })

        return

    # --------------------------------------------------------
    # 30+ minutes: send the missed check-in notification once.
    # --------------------------------------------------------

    if not data.get("secondReminderSent", False):
        print(f"Processing missed check-in: {reminder.id}")

        sent = send_caregiver_notification(
            elder_id,
            "Missed Check-in",
            "The elder has missed "
            "the scheduled check-in.",
        )

        if sent:
            reminder.reference.update({
                "secondReminderSent": True,
                "caregiverNotified": True,
                "status": "MISSED",
            })
        else:
            print(
                f"Missed-check-in notification failed for "
                f"{reminder.id}; it will be retried."
            )

def process_checkins():

    now = datetime.now(IST)

    print(
        "========================================"
    )

    print(
        "CareCircle Check-in Scheduler"
    )

    print(
        "Time:",
        now.strftime("%Y-%m-%d %I:%M:%S %p")
    )

    print(
        "========================================"
    )

    create_daily_reminders(now)

    today_string = now.strftime("%Y-%m-%d")

    reminders = (
        db.collection_group(
            "checkInReminders"
        )
        .where(
            "scheduledDate",
            "==",
            today_string
        )
        .get()
    )

    print(
        f"Found {len(reminders)} reminder(s)."
    )

    for reminder in reminders:

        try:

            process_reminder(
                reminder,
                now
            )

        except Exception as error:

            print(
                f"Error processing "
                f"{reminder.id}: {error}"
            )

    print(
        "Scheduler finished."
    )


if __name__ == "__main__":
    process_checkins()