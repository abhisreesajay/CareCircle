import os
from datetime import datetime, timedelta
from zoneinfo import ZoneInfo

import firebase_admin
from firebase_admin import credentials, firestore, messaging


# ============================================================
# FIREBASE INITIALIZATION
# ============================================================

service_account_json = os.environ.get(
    "FIREBASE_SERVICE_ACCOUNT_JSON"
)

if not service_account_json:
    raise RuntimeError(
        "FIREBASE_SERVICE_ACCOUNT_JSON secret is missing."
    )

import json

service_account_info = json.loads(
    service_account_json
)

cred = credentials.Certificate(
    service_account_info
)

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

        linked_elders = data.get(
            "linkedElders",
            [],
        )

        if not isinstance(linked_elders, list):
            continue

        if elder_id not in linked_elders:
            continue

        tokens = data.get(
            "fcmTokens",
            [],
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


# ============================================================
# SEND FCM
# ============================================================

def send_notification(
    elder_id,
    title,
    body,
):

    tokens = get_notification_recipients(
        elder_id
    )

    if not tokens:
        print(
            f"No caregiver FCM tokens found "
            f"for elder {elder_id}"
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

    print(
        "CareCircle check-in scheduler running:"
    )
    print(
        now.strftime("%Y-%m-%d %I:%M:%S %p")
    )

    reminders = (
        db.collection_group("checkInReminders")
        .where(
            "status",
            "in",
            [
                "PENDING",
                "FIRST_REMINDER_SENT",
                "SECOND_REMINDER_SENT",
            ],
        )
        .stream()
    )

    for reminder in reminders:

        data = reminder.to_dict()

        if not data:
            continue

        elder_id = data.get("elderId")

        scheduled_time = data.get(
            "scheduledTime"
        )

        if not elder_id or not scheduled_time:
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

        # ----------------------------------------------------
        # FIRST REMINDER
        # ----------------------------------------------------

        if (
            elapsed >= timedelta(0)
            and elapsed < timedelta(minutes=15)
            and data.get("status") == "PENDING"
        ):

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

        # ----------------------------------------------------
        # SECOND REMINDER
        # ----------------------------------------------------

        elif (
            elapsed >= timedelta(minutes=15)
            and elapsed < timedelta(minutes=30)
            and data.get("status")
            == "FIRST_REMINDER_SENT"
        ):

            send_notification(
                elder_id,
                "CareCircle Check-in Reminder",
                "The elder has not completed "
                "the check-in yet.",
            )

            reminder.reference.update({
                "secondReminderSent": True,
                "status": "SECOND_REMINDER_SENT",
            })

            print(
                f"Second reminder processed: "
                f"{reminder.id}"
            )

        # ----------------------------------------------------
        # MISSED CHECK-IN
        # ----------------------------------------------------

        elif (
            elapsed >= timedelta(minutes=30)
            and data.get("status")
            == "SECOND_REMINDER_SENT"
        ):

            send_notification(
                elder_id,
                "Missed Check-in",
                "The elder has missed "
                "the scheduled check-in.",
            )

            reminder.reference.update({
                "caregiverNotified": True,
                "status": "MISSED",
            })

            print(
                f"Missed check-in processed: "
                f"{reminder.id}"
            )


# ============================================================
# RUN
# ============================================================

if __name__ == "__main__":
    process_checkins()