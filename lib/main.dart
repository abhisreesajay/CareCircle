import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'services/messaging_service.dart';

import 'screens/auth/login_screen.dart';
import 'screens/caregiver/caregiver_dashboard.dart';
import 'screens/elder/check_in_screen.dart';
import 'screens/elder/elder_home.dart';
import 'screens/elder/voice_check_in_screen.dart';

import 'screens/emergency_contacts_screen.dart';
import 'screens/emergency_screen.dart';
import 'screens/safe_zone_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
          seedColor: const Color(0xFF7FA68F),
        ),
      ),

      routes: {
        '/checkin': (context) => const CheckInScreen(),

        '/voice-checkin': (context) =>
            const VoiceCheckInScreen(),

        '/sos': (context) =>
            const EmergencyScreen(),

        '/emergency-contacts': (context) =>
            const EmergencyContactsScreen(),

        '/safe-zone': (context) =>
            const SafeZoneScreen(),
      },

      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),

      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData &&
            snapshot.data != null) {
          return RoleRouter(
            uid: snapshot.data!.uid,
          );
        }

        return const LoginScreen();
      },
    );
  }
}

class RoleRouter extends StatelessWidget {
  final String uid;

  const RoleRouter({
    super.key,
    required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<
        DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots(),

      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
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
                'Error loading user profile:\n'
                '${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (!snapshot.hasData ||
            !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(
              child: Text(
                'User profile not found.',
              ),
            ),
          );
        }

        final Map<String, dynamic> data =
            snapshot.data!.data() ?? {};

        final String role =
            data['role']?.toString() ?? 'elder';

        if (role == 'caregiver') {
          final List<dynamic> linkedElders =
              data['linkedElders'] is List
                  ? data['linkedElders'] as List
                  : [];

          if (linkedElders.isEmpty) {
            return const Scaffold(
              body: Center(
                child: Text(
                  'No elder is linked to this caregiver yet.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final String elderId =
              linkedElders.first.toString();

          return CaregiverDashboard(
            elderId: elderId,
          );
        }

        return const ElderHome();
      },
    );
  }
}
