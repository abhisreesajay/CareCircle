import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'services/messaging_service.dart';

import 'screens/auth/login_screen.dart';
import 'screens/caregiver/caregiver_dashboard.dart';
import 'screens/caregiver/connect_elder_screen.dart';

import 'screens/elder/check_in_screen.dart';
import 'screens/elder/elder_home.dart';
import 'screens/elder/voice_check_in_screen.dart';
import 'screens/elder/nearby_services_screen.dart';
import 'screens/elder/invite_code_screen.dart';

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
        '/voice-checkin': (context) => const VoiceCheckInScreen(),
        '/sos': (context) => const EmergencyScreen(),
        '/nearby-services': (context) =>
            const ElderNearbyServicesScreen(),
        '/safe-zone': (context) => const SafeZoneScreen(),
        '/invite-code': (context) => const InviteCodeScreen(),
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final user = snapshot.data;

        if (user == null) {
          return const LoginScreen();
        }

        return RoleRouter(uid: user.uid);
      },
    );
  }
}

class RoleRouter extends StatefulWidget {
  final String uid;

  const RoleRouter({
    super.key,
    required this.uid,
  });

  @override
  State<RoleRouter> createState() => _RoleRouterState();
}

class _RoleRouterState extends State<RoleRouter> {
  final MessagingService _messagingService = MessagingService();

  @override
  void initState() {
    super.initState();
    _initializeMessaging();
  }

  @override
  void didUpdateWidget(
    covariant RoleRouter oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.uid != widget.uid) {
      _initializeMessaging();
    }
  }

  Future<void> _initializeMessaging() async {
    await _messagingService.initialize(widget.uid);
  }

  @override
  void dispose() {
    _messagingService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
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
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Error loading user profile:\n'
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'User profile not found.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        final data =
            snapshot.data!.data() ?? <String, dynamic>{};

        final role = data['role']?.toString().toLowerCase();

        // -----------------------------
        // CAREGIVER
        // -----------------------------

        if (role == 'caregiver') {
          final linkedElders = data['linkedElders'] is List
              ? List<dynamic>.from(
                  data['linkedElders'] as List,
                )
              : <dynamic>[];

          if (linkedElders.isEmpty) {
            return const CaregiverConnectElderScreen();
          }

          final elderId = linkedElders.first.toString().trim();

          if (elderId.isEmpty) {
            return const CaregiverConnectElderScreen();
          }

          return CaregiverDashboard(
            elderId: elderId,
          );
        }

        // -----------------------------
        // ELDER
        // -----------------------------

        if (role == 'elder') {
          return const ElderHome();
        }

        // -----------------------------
        // UNKNOWN ROLE
        // -----------------------------

        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Unknown account role: '
                '${role ?? 'missing'}',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }
}