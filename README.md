# CareCircle - Firebase & Backend Foundation

This branch contains the core backend infrastructure setup by Person 1. 

## 🛠 Setup Instructions for the Team
Before you start working on your assigned feature branch, ensure your local environment is synced with Firebase:

1. Clone the repository and switch to your feature branch.
2. Run `flutter pub get` to install dependencies (including Firebase).
3. **Do not commit** the `.env` file (ensure it is in your `.gitignore`).

## 🔥 Shared Firebase Services
Instead of calling Firebase directly, use the shared services provided in `lib/services/`:

* **`AuthService`**: Use this for `login()`, `logout()`, and checking the current `UserRole`. It handles Firebase Authentication.
* **`FirestoreService`**: Use this for basic database reads/writes. 
* **`MessagingService`**: Use this to get FCM tokens for push notifications.

## 🛡️ Role-Based Access Control (RBAC)
We have two primary roles enforced by Firestore Security Rules:
* **`elder`**: Has a simplified interface. Can create check-ins and trigger SOS.
* **`caregiver`**: Can manage medicines, appointments, and view elder logs.
* **Care Circles**: A caregiver can *only* read/write an elder's data if their UID is verified inside the elder's `careCircles` array in Firestore.

## 🔑 Environment Variables
If your module requires Google Maps (Person 4), add your API key to a local `.env` file. Do not push API keys to GitHub.
