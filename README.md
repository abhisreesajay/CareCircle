# CareCircle – Firebase & Backend Foundation

This branch contains the core backend infrastructure and shared Firebase services for **CareCircle**, an elder-care application built with Flutter and Firebase. It provides authentication, role-based access control, elder–caregiver connections, health data management, check-in tracking, emergency alerts, scheduled reminders, and notification support.

## 🛠 Setup Instructions for the Team

Before working on your assigned feature branch, ensure your local development environment is synchronized with the project.

1. Clone the repository:

   ```powershell
   git clone https://github.com/abhisreesajay/CareCircle.git
   cd CareCircle
   ```

2. Switch to your assigned feature branch:

   ```powershell
   git fetch origin
   git checkout <your-feature-branch>
   git pull origin <your-feature-branch>
   ```

3. Install Flutter dependencies:

   ```powershell
   flutter pub get
   ```

4. Ensure Firebase configuration files are present and correspond to the intended Firebase project. The project uses Firebase Authentication, Cloud Firestore, and Firebase Cloud Messaging.

5. Keep local secrets out of Git:

   * Do not commit `.env` files.
   * Do not commit private API keys, service-account credentials, or other secrets.
   * Keep `.env` listed in `.gitignore`.
   * Do not replace existing Firebase configuration with another project's configuration without coordinating with the team.

6. Use the shared services and existing data models in `lib/services/` and the relevant application directories instead of duplicating backend logic.

## 🔥 Shared Firebase Services

CareCircle uses shared services to centralize authentication, database operations, and notifications.

* **`AuthService`** – Handles authentication-related operations, including login, logout, and user-role handling. Public Admin self-registration is restricted by the authentication flow.
* **`FirestoreService`** – Provides shared Firestore database operations.
* **`CheckInService`** – Manages elder daily check-ins, including recording check-in details and storing timestamps and check-in methods.
* **`CareCircleService`** – Supports elder–caregiver connection management and access to connected elders.
* **`MessagingService`** – Supports Firebase Cloud Messaging integration and notification-token handling.
* **`CheckInReminder` model and scheduled reminder logic** – Support check-in reminder workflows, including follow-up reminders for missed check-ins.

Before creating a new service, check whether an existing service already handles the required operation. Follow the existing model, service, and Firestore collection conventions.

## 🛡️ Role-Based Access Control (RBAC)

CareCircle uses role-based access control to separate elder, caregiver, and administrative functionality.

### 1. Elder

Elders have a simplified, accessible interface designed for ease of use.

Supported features include:

* Daily check-ins.
* Voice-based check-in functionality.
* SOS emergency alerts.
* Medicine reminders and medication information.
* Appointments and relevant health information.
* Medical summary access.
* Safe-zone-related functionality.
* Nearby hospitals, shops, and restaurants.
* Family Moments.
* Profile and account management.

### 2. Caregiver

Caregivers can manage and monitor connected elders, subject to the configured Firestore Security Rules.

Supported features include:

* Caregiver dashboard and connected-elder overview.
* Daily check-in history and missed-check-in monitoring.
* Medicine management.
* Appointment management.
* Medical summary management.
* Emergency contact information.
* Safe-zone management.
* SOS and other alert monitoring.
* Elder activity and wellbeing-related information where implemented.
* Family Moments and care-circle management.

### 3. Admin

Administrative functionality is separated from ordinary elder and caregiver access.

Planned or supported administrative operations include:

* User and role management.
* Administrative dashboard.
* Caregiver–elder connection management.
* Access and connection oversight.

Administrative access must follow the application's authentication flow and Firestore authorization rules.

## 🔗 Elder–Caregiver Connections

CareCircle uses explicit elder–caregiver relationships to control access to elder-specific information.

* A caregiver must be connected to an elder before accessing that elder's protected records.
* Firestore Security Rules validate the authenticated user's identity and applicable caregiver connection.
* The current rules implementation checks the configured caregiver relationship documents, including the elder's `caregivers` subcollection and the caregiver's `caregiverConnections` records, where applicable.
* Connection requests, accepted connections, and access permissions must follow the actual schema and validation logic implemented in the repository.

**Important:** The current access-control implementation must be treated as the source of truth. Do not assume that a `careCircles` array is the only authorization mechanism unless the deployed rules and application code have been updated to use it.

Never bypass Firestore Security Rules by relying only on client-side role checks.

## 🗄️ Firestore Data Organization

Elder-specific information is organized primarily under the following structure:

```text
elders/{elderId}/
├── caregivers/{caregiverId}
├── checkIns/{checkInId}
├── medicines/{medicineId}
├── appointments/{appointmentId}
├── emergencyContacts/{contactId}
├── medicalSummary/{summaryId}
├── safeZones/{safeZoneId}
├── sosAlerts/{sosId}
└── [additional feature-specific collections]
```

Other user-level documents and connection records may exist outside the elder document, including:

```text
caregiverConnections/{caregiverId}/elders/{elderId}
```

The exact document fields and collection names must match the existing models, services, queries, and deployed Firestore Security Rules.

### Data Management Guidelines

* Store timestamps using Firestore `Timestamp` values where appropriate.
* Use the authenticated user's UID to identify the current user.
* Validate elder–caregiver access before reading or modifying protected records.
* Keep collection names and document field names consistent across services and models.
* Avoid creating duplicate collections for features that already have an established schema.
* Ensure that Firestore queries comply with the deployed security rules.

## ⏰ Check-ins and Scheduled Reminders

CareCircle supports daily check-in tracking and a reminder workflow for missed check-ins.

* Completed check-ins are stored in the elder's `checkIns` collection.
* Check-in records can include the elder ID, timestamp, check-in method, and completion status.
* The application is intended to prevent duplicate daily check-ins according to the implemented check-in logic.
* The reminder workflow supports scheduled check-in notifications and a follow-up reminder **15 minutes after a missed check-in**, as configured by the scheduler.
* Reminder processing must account for the elder's check-in status so completed check-ins are not incorrectly treated as missed.
* Notification delivery depends on valid configuration, permissions, network connectivity, and the deployed backend implementation.

Scheduled reminders require the relevant backend scheduler or Cloud Function to be configured and deployed. Local Flutter code alone does not guarantee that reminders will run when the application is closed.

## 🚨 SOS and Emergency Alerts

CareCircle includes SOS functionality intended to notify the care circle when an elder requests emergency assistance.

* SOS events are associated with the relevant elder.
* The workflow is intended to capture location information when available and notify connected caregivers.
* Firebase Cloud Messaging supports push-notification delivery.
* Caregiver interfaces can display emergency events and relevant alert information.
* Location availability, network access, notification permissions, and backend deployment affect actual delivery.

The intended requirement is to deliver SOS location information and care-circle notifications within **5 seconds when network and system conditions permit**. This is a target, not a guarantee of delivery time.

Do not assume that an SOS Cloud Function or notification workflow is operational until its implementation and deployment status have been verified.

## 💊 Health and Care Management

The backend supports the application's health and care-management features, including:

* Medicine records and medication reminders.
* Appointment records.
* Emergency contact information.
* Medical summaries.
* Safe zones.
* Daily check-in history.
* SOS events and caregiver alerts.

Use the existing service classes, data models, and collection paths for these features. New features must preserve the existing authorization model and avoid exposing one elder's records to an unrelated caregiver.

CareCircle is a care-support application, not a medical diagnostic system.

## 🔔 Firebase Cloud Messaging

Firebase Cloud Messaging (FCM) is used to support push notifications.

Team members working on notification-related features should:

* Use the shared messaging service where available.
* Handle notification permissions and token availability appropriately.
* Keep notification payloads consistent with the application’s navigation and alert models.
* Avoid hardcoding user-specific tokens.
* Ensure that sensitive health information is not unnecessarily included in notification payloads.
* Verify that the required backend sender and notification handlers are configured before relying on end-to-end delivery.

## 🔐 Firestore Security Rules

Firestore Security Rules are an essential part of the backend architecture.

Rules must enforce:

* Authentication before protected operations.
* Role-appropriate permissions.
* Elder–caregiver connection checks.
* Restrictions on unauthorized access to health records.
* Validation of writes where required.
* Protection against unauthorized user-role changes and administrative access.

**Do not deploy permissive rules to solve permission errors.** Investigate the failing path, authenticated UID, connection document, query, and required permission before changing the rules.

After updating the rules, deploy the reviewed version to the intended Firebase project.

## 🗺️ Google Maps and Environment Variables

Features that use Google Maps or Google Places, including nearby hospitals and services, may require API credentials and platform-specific configuration.

* Store locally configured secrets in `.env` when supported by the implementation.
* Keep `.env` in `.gitignore`.
* Never commit Google Maps API keys or other private credentials.
* Restrict Google Maps API keys to the required APIs and appropriate Android, web, or other platform restrictions.
* Use the configuration method expected by the relevant Flutter package. A `.env` file is not automatically loaded by Flutter or Firebase.
* Avoid embedding unrestricted server credentials in a client application.

Team members working on maps must verify the existing configuration before introducing new environment-variable names or replacing API-key handling.

## 🚀 Development and Deployment Guidelines

Before merging a feature into `main`:

1. Sync your branch with the latest relevant changes.
2. Reuse the existing services and models.
3. Preserve Firestore collection names and document schemas unless a coordinated migration is required.
4. Check that new reads and writes comply with the deployed security rules.
5. Keep credentials and local configuration files out of commits.
6. Ensure that changes do not break existing elder, caregiver, or admin functionality.
7. Coordinate shared changes to Firebase configuration, Firestore rules, and backend functions with the team.

Deploy Firebase rules and backend functions only to the intended project and only when the corresponding configuration and implementation are ready.

## ⚠️ Implementation Status

The presence of a service, model, or UI screen does not automatically mean its entire backend workflow is deployed and operational.

In particular, scheduled reminders, background processing, SOS notification delivery, and other Cloud Function-dependent features require their corresponding backend components to be deployed and configured.

Check the current repository and Firebase deployment status before marking a feature as fully operational.

---

**CareCircle – Accessible elder care, connected families, and safer everyday living.**
