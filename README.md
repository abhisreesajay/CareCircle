# CareCircle

CareCircle is a family care coordination system designed to help
caregivers monitor and support elderly family members.

## Applications

- Elder Application
- Caregiver Application

## Backend

- Firebase Authentication
- Cloud Firestore
- Firebase Cloud Functions
- Firebase Cloud Messaging

## External Services

- Google Maps / Places
- Speech-to-Text
- SMS Gateway

## Architecture

CareCircle uses a layered modular client-backend architecture.

## Team

Team 13

### Members

1. Nanditha R Sanal
2. Kourvaki Singh
3. Smrithi Jyothilal
4. Kethavath Tejasri
5. Abhisree S Ajay

---

# Firebase & Backend Foundation

This section contains the core backend infrastructure setup.

## Setup Instructions for the Team

Before working on an assigned feature branch:

1. Clone the repository and switch to your feature branch.
2. Run lutter pub get to install dependencies.
3. Do not commit the .env file.

## Shared Firebase Services

Instead of calling Firebase directly, use the shared services in lib/services/:

- AuthService: login, logout, and current UserRole.
- FirestoreService: basic database reads/writes.
- MessagingService: FCM tokens and push notifications.

## Role-Based Access Control

- elder: simplified interface, can create check-ins and trigger SOS.
- caregiver: can manage medicines, appointments, and view elder logs.
- Caregivers can access elder data only when their UID is verified in the elder's careCircles array.

## Environment Variables

If a module requires Google Maps, add the API key to a local .env file.

Do not push API keys to GitHub.
