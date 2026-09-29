<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'services/messaging_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
<<<<<<< HEAD
import 'models/user_model.dart';
import 'services/auth_service.dart';
import 'screens/auth/login_screen.dart';
=======
import 'package:cloud_firestore/cloud_firestore.dart';
<<<<<<< HEAD

import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';import 'screens/caregiver/caregiver_dashboard.dart';

>>>>>>> main
import 'screens/elder/elder_home.dart';
import 'guards/caregiver_gateway.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
<<<<<<< HEAD
  await Firebase.initializeApp();
  
  // Initialize Messaging BEFORE runApp
  MessagingService.setupBackgroundHandling();
  await MessagingService().initialize();

=======
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
=======
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

>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
>>>>>>> main
=======
import 'package:cloud_firestore/cloud_firestore.dart'; // Fixed import syntax

import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/caregiver/caregiver_dashboard.dart';
import 'screens/elder/elder_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
>>>>>>> develop
  runApp(const CareCircleApp());
}

class CareCircleApp extends StatelessWidget {
  const CareCircleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CareCircle',
      debugShowCheckedModeBanner: false,
<<<<<<< HEAD
      theme: ThemeData(
<<<<<<< HEAD
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF164A63)),
=======
>>>>>>> main
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
=======
      theme: AppTheme.caregiverTheme,
>>>>>>> develop
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
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

<<<<<<< HEAD
<<<<<<< HEAD
        if (!snapshot.hasData || snapshot.data == null) {
          return const LoginScreen();
=======
        if (snapshot.hasData) {
          return RoleRouter(uid: snapshot.data!.uid);
>>>>>>> develop
        }

        final user = snapshot.data!;
        return FutureBuilder<UserModel?>(
          future: AuthService().getUserProfile(user.uid),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final profile = profileSnapshot.data;

            if (profile != null) {
              if (profile.role == 'elder') {
                return const ElderHome();
              } else if (profile.role == 'caregiver') {
                return const CaregiverGateway(); 
              }
            }

            return const LoginScreen();
          },
=======
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
  const RoleRouter({super.key, required this.uid});

  @override
  State<RoleRouter> createState() => _RoleRouterState();
}

class _RoleRouterState extends State<RoleRouter> {
  final MessagingService _messagingService =
      MessagingService();

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
<<<<<<< HEAD
    return StreamBuilder<
        DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
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

<<<<<<< HEAD
=======
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

>>>>>>> develop
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final role = data['role'] ?? 'elder';

          switch (role) {
            case 'admin':
              return Theme(
                data: AppTheme.adminTheme,
                child: const AdminDashboardScreen(),
              );
            case 'caregiver':
              final linkedElders = List<String>.from(data['linkedElders'] ?? []);
              final activeElderId = linkedElders.isNotEmpty ? linkedElders.first : 'test-elder-001';
              return Theme(
                data: AppTheme.caregiverTheme,
                child: CaregiverDashboard(elderId: activeElderId),
              );
            case 'elder':
            default:
              return Theme(
                data: AppTheme.elderTheme,
                child: const ElderHome(),
              );
          }
<<<<<<< HEAD
=======
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
>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
        }

        if (!snapshot.hasData ||
            !snapshot.data!.exists) {
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
            snapshot.data!.data() ??
                <String, dynamic>{};

        final role =
            data['role']?.toString().toLowerCase();

        // -----------------------------
        // CAREGIVER
        // -----------------------------

        if (role == 'caregiver') {
          final linkedElders =
              data['linkedElders'] is List
                  ? List<dynamic>.from(
                      data['linkedElders'] as List,
                    )
                  : <dynamic>[];

          if (linkedElders.isEmpty) {
            return const CaregiverConnectElderScreen();
          }

          final elderId =
              linkedElders.first.toString().trim();

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
>>>>>>> main
        );
=======
        }

        return const LoginScreen();
>>>>>>> develop
      },
    );
  }
}
