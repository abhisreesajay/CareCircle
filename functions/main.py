from firebase_functions import firestore_fn
from firebase_functions.options import set_global_options
from firebase_admin import initialize_app, firestore, messaging

set_global_options(max_instances=10)

initialize_app()


@firestore_fn.on_document_created(
    document="sosRecords/{sosId}"
)
def on_sos_created(event: firestore_fn.Event[firestore_fn.DocumentSnapshot]):
    sos = event.data

    if sos is None:
        return

    sos_data = sos.to_dict()

    user_id = sos_data.get("userId", "Unknown user")
    latitude = sos_data.get("latitude", 0)
    longitude = sos_data.get("longitude", 0)

    db = firestore.client()

    caregivers = (
        db.collection("users")
        .where("role", "==", "caregiver")
        .stream()
    )

    for caregiver in caregivers:
        caregiver_data = caregiver.to_dict()

        fcm_token = caregiver_data.get("fcmToken")

        if not fcm_token:
            continue

        message = messaging.Message(
            notification=messaging.Notification(
                title="🚨 Emergency SOS",
                body=(
                    f"Emergency SOS received from {user_id}. "
                    f"Location: {latitude}, {longitude}"
                ),
            ),
            token=fcm_token,
        )

        messaging.send(message)