import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'services/messaging_service.dart';
import 'services/medication_notification_service.dart';

// Shared project screens
import 'screens/auth/login_screen.dart';
import 'screens/caregiver/caregiver_dashboard.dart';
import 'screens/elder/check_in_screen.dart';
import 'screens/elder/elder_home.dart';

// Person 4 screens
import 'screens/emergency_contacts_screen.dart';
import 'screens/emergency_screen.dart';
import 'screens/safe_zone_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --------------------------------------------------
  // FIREBASE INITIALIZATION
  // --------------------------------------------------

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // --------------------------------------------------
  // FCM BACKGROUND MESSAGE HANDLER
  // --------------------------------------------------
  //
  // Existing FCM functionality is kept unchanged.
  //

  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  runApp(const CareCircleApp());
}

class CareCircleApp extends StatelessWidget {
  const CareCircleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CareCircle',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2A9D8F),
        ),
      ),

      // Named routes used by shared screens and Person 4 screens.
      routes: {
        '/checkin': (context) => const CheckInScreen(),
        '/sos': (context) => const EmergencyScreen(),
        '/emergency-contacts': (context) =>
            const EmergencyContactsScreen(),
        '/safe-zone': (context) => const SafeZoneScreen(),
      },

      home: const AuthWrapper(),
    );
  }
}

/// Checks whether the user is logged in.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return RoleRouter(
            uid: snapshot.data!.uid,
          );
        }

        return const LoginScreen();
      },
    );
  }
}

/// Opens the correct dashboard based on the user's Firestore role.
class RoleRouter extends StatelessWidget {
  final String uid;

  const RoleRouter({
    super.key,
    required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(
                'Error loading user profile:\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(
              child: Text('User profile not found.'),
            ),
          );
        }

        final data = snapshot.data!.data() ?? {};
        final role = data['role'] ?? 'elder';

        // --------------------------------------------------
        // CAREGIVER
        // --------------------------------------------------

        if (role == 'caregiver') {
          return const CaregiverDashboard(
            elderId: 'test_elder_001',
          );
        }

        // --------------------------------------------------
        // ELDER
        // --------------------------------------------------
        //
        // The Elder notification initializer starts the
        // local medication reminder listener.
        //

        return ElderNotificationInitializer(
          elderId: uid,
        );
      },
    );
  }
}

/// Initializes medication notifications for the logged-in Elder.
///
/// This wrapper keeps ElderHome unchanged.
///
/// When the Elder logs in:
///     RoleRouter
///          ↓
///     ElderNotificationInitializer
///          ↓
///     MedicationNotificationService
///          ↓
///     Firestore medicines
///          ↓
///     Local Android notification
class ElderNotificationInitializer extends StatefulWidget {
  final String elderId;

  const ElderNotificationInitializer({
    super.key,
    required this.elderId,
  });

  @override
  State<ElderNotificationInitializer> createState() =>
      _ElderNotificationInitializerState();
}

class _ElderNotificationInitializerState
    extends State<ElderNotificationInitializer> {
  @override
  void initState() {
    super.initState();

    _initializeMedicationNotifications();
  }

  Future<void> _initializeMedicationNotifications() async {
    try {
      await MedicationNotificationService.instance.startForElder(
        widget.elderId,
      );
    } catch (e) {
      // Notification failure should not prevent the Elder
      // from opening the CareCircle application.
    }
  }

  @override
  void dispose() {
    MedicationNotificationService.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const ElderHome();
  }
}

/// Person 4 dashboard for Emergency, Safety and Location features.
///
/// This screen is kept separately so it can be connected to the elder
/// dashboard or used for Person 4 testing/demo.
class Person4Dashboard extends StatelessWidget {
  const Person4Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CareCircle Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.health_and_safety,
              size: 90,
              color: Colors.green,
            ),

            const SizedBox(height: 15),

            const Text(
              'Emergency, Safety & Location',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Person 4 Module',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 30),

            _buildFeatureButton(
              context: context,
              title: 'Safe Zone',
              subtitle: 'Create and manage elder safe zones',
              icon: Icons.location_on,
              color: Colors.blue,
              screen: const SafeZoneScreen(),
            ),

            const SizedBox(height: 15),

            _buildFeatureButton(
              context: context,
              title: 'Emergency Contacts',
              subtitle: 'Add, view and delete emergency contacts',
              icon: Icons.contacts,
              color: Colors.orange,
              screen: const EmergencyContactsScreen(),
            ),

            const SizedBox(height: 15),

            _buildFeatureButton(
              context: context,
              title: 'Emergency SOS',
              subtitle: 'Confirm SOS, get GPS location and save alert',
              icon: Icons.warning,
              color: Colors.red,
              screen: const EmergencyScreen(),
            ),

            const SizedBox(height: 30),

            Card(
              color: Colors.green.shade50,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Person 4 Features',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),

                    SizedBox(height: 10),

                    Text(
                      '• Login before accessing the dashboard\n'
                      '• GPS location permission\n'
                      '• One-time location retrieval during SOS\n'
                      '• SOS record creation\n'
                      '• SOS cancellation\n'
                      '• Safe zone creation\n'
                      '• Emergency contact management\n'
                      '• FCM token registration',
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget screen,
  }) {
    return Card(
      elevation: 4,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),

        leading: CircleAvatar(
          radius: 28,
          backgroundColor: color,
          child: Icon(
            icon,
            color: Colors.white,
            size: 30,
          ),
        ),

        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(subtitle),
        ),

        trailing: const Icon(
          Icons.arrow_forward_ios,
        ),

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => screen,
            ),
          );
        },
      ),
    );
  }
}