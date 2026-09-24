import os
import json
from datetime import datetime, timedelta
from zoneinfo import ZoneInfo

import firebase_admin
from firebase_admin import credentials, firestore, messaging


# ============================================================
# FIREBASE INITIALIZATION
# ============================================================

service_account_json = os.environ.get("FIREBASE_SERVICE_ACCOUNT_JSON")

if not service_account_json:
    raise RuntimeError("FIREBASE_SERVICE_ACCOUNT_JSON secret is missing.")

service_account_info = json.loads(service_account_json)

cred = credentials.Certificate(service_account_info)

firebase_admin.initialize_app(cred)

db = firestore.client()

IST = ZoneInfo("Asia/Kolkata")


# ============================================================
# GET CAREGIVER FCM TOKENS
# ============================================================

def get_notification_recipients(elder_id):
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

        linked_elders = data.get("linkedElders", [])

        if not isinstance(linked_elders, list):
            continue

        if elder_id not in linked_elders:
            continue

        tokens = data.get("fcmTokens", [])

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


# ============================================================
# SEND FCM
# ============================================================

def send_notification(elder_id, title, body):

    print(f"Finding caregiver tokens for elder: {elder_id}")

    tokens = get_notification_recipients(elder_id)

    print(f"Found {len(tokens)} caregiver device(s).")

    if not tokens:
        print(
            f"No caregiver FCM tokens found for elder {elder_id}"
        )
        return

    success = 0

    for token in tokens:

        try:
            message = messaging.Message(
                notification=messaging.Notification(
                    title=title,
                    body=body,
                ),
                token=token,
            )

            response = messaging.send(message)

            print(
                f"Notification sent to caregiver. "
                f"Message ID: {response}"
            )

            success += 1

        except Exception as error:

            print(
                f"Notification failed: {error}"
            )

    print(
        f"Successfully sent to {success} "
        f"caregiver device(s)."
    )


# ============================================================
# PROCESS CHECK-IN REMINDERS
# ============================================================

def process_checkins():

    now = datetime.now(IST)

    print("CareCircle check-in scheduler running:")

    print(
        now.strftime("%Y-%m-%d %I:%M:%S %p")
    )

    print("Reading check-in reminders from Firestore...")

    reminders = (
        db.collection_group("checkInReminders")
        .get()
    )

    print(
        f"Found {len(reminders)} "
        f"check-in reminder(s)."
    )

    for reminder in reminders:

        data = reminder.to_dict()

        if not data:
            continue

        print(
            f"Checking reminder: {reminder.id}"
        )

        print(
            f"Reminder data: {data}"
        )

        elder_id = data.get("elderId")

        scheduled_time = data.get(
            "scheduledTime"
        )

        status = data.get("status")

        if not elder_id or not scheduled_time:

            print(
                "Missing elderId or scheduledTime. "
                "Skipping."
            )

            continue

        if status not in [
            "PENDING",
            "FIRST_REMINDER_SENT",
            "SECOND_REMINDER_SENT",
        ]:

            print(
                f"Status {status} does not need processing."
            )

            continue

        try:

            scheduled = datetime.strptime(
                scheduled_time,
                "%I:%M %p",
            )

            scheduled = scheduled.replace(
                year=now.year,
                month=now.month,
                day=now.day,
                tzinfo=IST,
            )

        except Exception as error:

            print(
                f"Invalid scheduled time "
                f"{scheduled_time}: {error}"
            )

            continue

        elapsed = now - scheduled

        print(
            "Scheduled: "
            + scheduled.strftime(
                "%Y-%m-%d %I:%M:%S %p"
            )
        )

        print(
            f"Elapsed: {elapsed}"
        )


        # ====================================================
        # BEFORE SCHEDULED TIME
        # ====================================================

        if elapsed.total_seconds() < 0:

            print(
                "Reminder time has not arrived yet."
            )

            continue


        # ====================================================
        # FIRST REMINDER
        # 0 - 15 MINUTES
        # ====================================================

        if (
            elapsed < timedelta(minutes=15)
            and status == "PENDING"
        ):

            print(
                "Sending first reminder..."
            )

            send_notification(
                elder_id,
                "CareCircle Check-in",
                "The elder's daily check-in is due.",
            )

            reminder.reference.update({
                "firstReminderSent": True,
                "status": "FIRST_REMINDER_SENT",
            })

            print(
                f"First reminder processed: "
                f"{reminder.id}"
            )


        # ====================================================
        # SECOND REMINDER
        # 15 - 30 MINUTES
        # ====================================================

        elif (
            elapsed >= timedelta(minutes=15)
            and elapsed < timedelta(minutes=30)
            and status == "FIRST_REMINDER_SENT"
        ):

            print(
                "Sending second reminder..."
            )

            send_notification(
                elder_id,
                "CareCircle Check-in Reminder",
                "The elder has not completed the check-in yet.",
            )

            reminder.reference.update({
                "secondReminderSent": True,
                "status": "SECOND_REMINDER_SENT",
            })

            print(
                f"Second reminder processed: "
                f"{reminder.id}"
            )


        # ====================================================
        # MISSED CHECK-IN
        # 30+ MINUTES
        #
        # Handles BOTH cases:
        # FIRST_REMINDER_SENT
        # SECOND_REMINDER_SENT
        #
        # This means the workflow can run late
        # without getting stuck.
        # ====================================================

        elif (
            elapsed >= timedelta(minutes=30)
            and status in [
                "FIRST_REMINDER_SENT",
                "SECOND_REMINDER_SENT",
            ]
        ):

            print(
                "Sending missed check-in notification..."
            )

            send_notification(
                elder_id,
                "Missed Check-in",
                "The elder has missed the scheduled check-in.",
            )

            reminder.reference.update({
                "caregiverNotified": True,
                "status": "MISSED",
            })

            print(
                f"Missed check-in processed: "
                f"{reminder.id}"
            )


    print(
        "CareCircle check-in scheduler finished."
    )


# ============================================================
# RUN
# ============================================================

if __name__ == "__main__":

    process_checkins()