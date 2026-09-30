import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'services/messaging_service.dart';
import 'services/supabase_service.dart';

// ============================================================
// AUTH SCREENS
// ============================================================

import 'screens/auth/login_screen.dart';

// ============================================================
// CAREGIVER SCREENS
// ============================================================

import 'screens/caregiver/caregiver_dashboard.dart';
import 'screens/caregiver/connect_elder_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';

// ============================================================
// ELDER SCREENS
// ============================================================

import 'screens/elder/check_in_screen.dart';
import 'screens/elder/elder_home.dart';
import 'screens/elder/voice_check_in_screen.dart';
import 'screens/elder/nearby_services_screen.dart';
import 'screens/elder/invite_code_screen.dart';

// ============================================================
// OTHER SCREENS
// ============================================================

import 'screens/elder/emergency_screen.dart';
import 'screens/safe_zone_screen.dart';

// ============================================================
// NOTIFICATIONS
// ============================================================

import 'services/notifications/medication_notification_service.dart';

Future<void> main() async {
  // ----------------------------------------------------------
  // Flutter initialization
  // ----------------------------------------------------------

  WidgetsFlutterBinding.ensureInitialized();

  // ----------------------------------------------------------
  // Firebase initialization
  // ----------------------------------------------------------

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ----------------------------------------------------------
  // Firebase Cloud Messaging background handler
  // ----------------------------------------------------------

  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  // ----------------------------------------------------------
  // Supabase initialization
  // ----------------------------------------------------------
  //
  // Firebase remains the main backend for:
  // - Authentication
  // - Firestore
  // - FCM
  //
  // Supabase is being used specifically for:
  // - Hospital document file storage
  //
  // The two services work independently.
  // ----------------------------------------------------------

  await SupabaseService.initialize();

  // ----------------------------------------------------------
  // Start application
  // ----------------------------------------------------------

  runApp(const CareCircleApp());
}

// ======================================================================
// CARECIRCLE APP
// ======================================================================

class CareCircleApp extends StatelessWidget {
  const CareCircleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CareCircle',

      debugShowCheckedModeBanner: false,

      // ----------------------------------------------------------
      // GLOBAL THEME
      // ----------------------------------------------------------

      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7FA68F),
        ),
      ),

      // ----------------------------------------------------------
      // APPLICATION ROUTES
      // ----------------------------------------------------------

      routes: {
        // Elder
        '/checkin': (context) => const CheckInScreen(),

        '/voice-checkin': (context) =>
            const VoiceCheckInScreen(),

        '/nearby-services': (context) =>
            const ElderNearbyServicesScreen(),

        '/invite-code': (context) =>
            const InviteCodeScreen(),

        // Emergency
        '/sos': (context) =>
            const EmergencyScreen(),

        // Safe zone
        '/safe-zone': (context) =>
            const SafeZoneScreen(),
      },

      // ----------------------------------------------------------
      // INITIAL SCREEN
      // ----------------------------------------------------------

      home: const AuthWrapper(),
    );
  }
}

// ======================================================================
// AUTH WRAPPER
// ======================================================================
//
// Checks whether a Firebase user is logged in.
//
// Firebase Authentication remains unchanged.
// ======================================================================

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),

      builder: (context, snapshot) {
        // ------------------------------------------------------
        // Waiting for Firebase Auth
        // ------------------------------------------------------

        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // ------------------------------------------------------
        // No logged-in user
        // ------------------------------------------------------

        final user = snapshot.data;

        if (user == null) {
          return const LoginScreen();
        }

        // ------------------------------------------------------
        // Logged-in user
        // ------------------------------------------------------

        return RoleRouter(
          uid: user.uid,
        );
      },
    );
  }
}

// ======================================================================
// ROLE ROUTER
// ======================================================================
//
// Loads the user's Firestore profile and sends them to the
// correct interface.
//
// Existing CareCircle role logic is preserved.
// ======================================================================

class RoleRouter extends StatefulWidget {
  final String uid;

  const RoleRouter({
    super.key,
    required this.uid,
  });

  @override
  State<RoleRouter> createState() =>
      _RoleRouterState();
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

  // ====================================================================
  // FIREBASE MESSAGING INITIALIZATION
  // ====================================================================

  Future<void> _initializeMessaging() async {
    await _messagingService.initialize(
      widget.uid,
    );
  }

  @override
  void dispose() {
    _messagingService.dispose();
    MedicationNotificationService.instance.stop();

    super.dispose();
  }
  // ====================================================================
  // ROLE ROUTING
  // ====================================================================

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<
        DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .snapshots(),

      builder: (context, snapshot) {
        // ------------------------------------------------------
        // Loading profile
        // ------------------------------------------------------

        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // ------------------------------------------------------
        // Firestore error
        // ------------------------------------------------------

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

        // ------------------------------------------------------
        // Profile doesn't exist
        // ------------------------------------------------------

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

        // ------------------------------------------------------
        // Read Firestore profile
        // ------------------------------------------------------

        final data =
            snapshot.data!.data() ??
                <String, dynamic>{};

        final role =
            data['role']
                ?.toString()
                .toLowerCase();

        // ======================================================
        // CAREGIVER
        // ======================================================

        if (role == 'caregiver') {
          final linkedElders =
              data['linkedElders'] is List
                  ? List<dynamic>.from(
                      data['linkedElders'] as List,
                    )
                  : <dynamic>[];

          // ----------------------------------------------------
          // No elder connected
          // ----------------------------------------------------

          if (linkedElders.isEmpty) {
            return const CaregiverConnectElderScreen();
          }

          // ----------------------------------------------------
          // Get first linked elder
          // ----------------------------------------------------

          final elderId =
              linkedElders.first
                  .toString()
                  .trim();

          if (elderId.isEmpty) {
            return const CaregiverConnectElderScreen();
          }

          // ----------------------------------------------------
          // Caregiver dashboard
          // ----------------------------------------------------

          return CaregiverDashboard(
            elderId: elderId,
          );
        }

        // ======================================================
        // ADMIN
        // ======================================================

        if (role == 'admin') {
          return const AdminDashboardScreen();
        }

        // ======================================================
        // ELDER
        // ======================================================

        if (role == 'elder') {
          MedicationNotificationService.instance.startForElder(widget.uid);
          return const ElderHome();
        }
        // ======================================================
        // UNKNOWN ROLE
        // ======================================================

        return Scaffold(
          body: Center(
            child: Padding(
              padding:
                  const EdgeInsets.all(24),

              child: Text(
                'Unknown account role: '
                '${role ?? 'missing'}',

                textAlign:
                    TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }
}