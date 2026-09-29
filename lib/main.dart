import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

// ============================================================
// AUTHENTICATION
// ============================================================

import 'screens/auth/login_screen.dart';

// ============================================================
// ADMIN
// ============================================================


// ============================================================
// CAREGIVER
// ============================================================

import 'screens/caregiver_dashboard.dart';

// ============================================================
// ELDER
// ============================================================

import 'screens/elder/check_in_screen.dart';
import 'screens/elder/elder_home.dart';
import 'screens/elder/hospitals_screen.dart';
import 'screens/elder/services_screen.dart';
import 'screens/elder/sos_screen.dart';
import 'screens/elder/voice_check_in_screen.dart';

// ============================================================
// MAIN
// ============================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const CareCircleApp(),
  );
}

// ============================================================
// CARECIRCLE APP
// ============================================================

class CareCircleApp extends StatelessWidget {
  const CareCircleApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'CareCircle',

      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F7966),
        ),

        scaffoldBackgroundColor:
            const Color(0xFFF6F8F5),
      ),

      initialRoute: '/',

      routes: {
        // ------------------------------------------------------
        // AUTH
        // ------------------------------------------------------

        '/': (context) {
          return const AuthWrapper();
        },

        '/login': (context) {
          return const LoginScreen();
        },

        // ------------------------------------------------------
        // ELDER
        // ------------------------------------------------------

        '/checkin': (context) {
          return const CheckInScreen();
        },

        '/voice-checkin': (context) {
          return const VoiceCheckInScreen();
        },

        '/sos': (context) {
          return const SOSScreen();
        },

        '/hospitals': (context) {
          return const HospitalsScreen();
        },

        '/services': (context) {
          return const ServicesScreen();
        },

        // ------------------------------------------------------
        // ADMIN
        // ------------------------------------------------------

      },
    );
  }
}

class AdminDashboard {
  const new();
}

// ============================================================
// AUTH WRAPPER
// ============================================================

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),

      builder: (
        BuildContext context,
        AsyncSnapshot<User?> snapshot,
      ) {
        // ------------------------------------------------------
        // LOADING
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
        // AUTH ERROR
        // ------------------------------------------------------

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Authentication error.\n\n'
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          );
        }

        // ------------------------------------------------------
        // NO USER
        // ------------------------------------------------------

        final User? user = snapshot.data;

        if (user == null) {
          return const LoginScreen();
        }

        // ------------------------------------------------------
        // LOGGED IN
        // ------------------------------------------------------

        return const RoleRouter();
      },
    );
  }
}

// ============================================================
// ROLE ROUTER
// ============================================================
//
// Firestore:
//
// users/{uid}
//
// Supported roles:
//
// elder
// caregiver
// admin
//
// ============================================================

class RoleRouter extends StatelessWidget {
  const RoleRouter({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final User? user =
        FirebaseAuth.instance.currentUser;

    // ----------------------------------------------------------
    // NO USER
    // ----------------------------------------------------------

    if (user == null) {
      return const LoginScreen();
    }

    // ----------------------------------------------------------
    // READ USER ROLE
    // ----------------------------------------------------------

    return StreamBuilder<
        DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),

      builder: (
        BuildContext context,
        AsyncSnapshot<
                DocumentSnapshot<
                    Map<String, dynamic>>>
            snapshot,
      ) {
        // ------------------------------------------------------
        // LOADING
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
        // FIRESTORE ERROR
        // ------------------------------------------------------

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 55,
                      color: Colors.red,
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    const Text(
                      'Unable to load user profile.',
                      textAlign:
                          TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Text(
                      '${snapshot.error}',
                      textAlign:
                          TextAlign.center,
                      style:
                          const TextStyle(
                        color:
                            Colors.black54,
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    ElevatedButton.icon(
                      onPressed: () async {
                        await FirebaseAuth
                            .instance
                            .signOut();
                      },
                      icon: const Icon(
                        Icons.logout,
                      ),
                      label: const Text(
                        'Back to Login',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // ------------------------------------------------------
        // PROFILE DOES NOT EXIST
        // ------------------------------------------------------

        if (!snapshot.hasData ||
            !snapshot.data!.exists) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.person_off_outlined,
                      size: 55,
                      color: Colors.orange,
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    const Text(
                      'User profile not found.',
                      textAlign:
                          TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    const Text(
                      'Please create the user profile '
                      'in the Firestore users collection.',
                      textAlign:
                          TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color:
                            Colors.black54,
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    ElevatedButton.icon(
                      onPressed: () async {
                        await FirebaseAuth
                            .instance
                            .signOut();
                      },
                      icon: const Icon(
                        Icons.logout,
                      ),
                      label: const Text(
                        'Back to Login',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // ------------------------------------------------------
        // USER DATA
        // ------------------------------------------------------

        final Map<String, dynamic> data =
            snapshot.data!.data() ??
                <String, dynamic>{};

        final String role =
            data['role']
                    ?.toString()
                    .toLowerCase()
                    .trim() ??
                '';

        // ------------------------------------------------------
        // DEBUG
        // ------------------------------------------------------

        debugPrint(
          '=========================================',
        );

        debugPrint(
          'CareCircle logged-in UID: ${user.uid}',
        );

        debugPrint(
          'CareCircle Firestore user data: $data',
        );

        debugPrint(
          'CareCircle detected role: [$role]',
        );

        debugPrint(
          '=========================================',
        );

        // ======================================================
        // ELDER
        // ======================================================

        if (role == 'elder') {
          return const ElderHome();
        }

        // ======================================================
        // CAREGIVER
        // ======================================================

        if (role == 'caregiver') {
          final dynamic linkedElders =
              data['linkedElders'];

          if (linkedElders is List &&
              linkedElders.isNotEmpty) {
            return CaregiverDashboard(
              elderId:
                  linkedElders.first.toString(),
            );
          }

          return Scaffold(
            body: Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.people_outline,
                      size: 55,
                      color: Colors.orange,
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    const Text(
                      'No elder linked',
                      textAlign:
                          TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    const Text(
                      'No elder is linked to this '
                      'caregiver account yet.',
                      textAlign:
                          TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color:
                            Colors.black54,
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    ElevatedButton.icon(
                      onPressed: () async {
                        await FirebaseAuth
                            .instance
                            .signOut();
                      },
                      icon: const Icon(
                        Icons.logout,
                      ),
                      label: const Text(
                        'Back to Login',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // ======================================================
        // ADMIN
        // ======================================================

  

        // ======================================================
        // UNKNOWN ROLE
        // ======================================================

        return Scaffold(
          body: Center(
            child: Padding(
              padding:
                  const EdgeInsets.all(24),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 60,
                    color: Colors.orange,
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  const Text(
                    'User role is not configured.',
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Text(
                    'Current role: '
                    '${role.isEmpty ? 'Not specified' : role}',
                    textAlign:
                        TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color:
                          Colors.black54,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Text(
                    'User UID:\n${user.uid}',
                    textAlign:
                        TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color:
                          Colors.black45,
                    ),
                  ),

                  const SizedBox(
                    height: 22,
                  ),

                  ElevatedButton.icon(
                    onPressed: () async {
                      await FirebaseAuth
                          .instance
                          .signOut();
                    },
                    icon: const Icon(
                      Icons.logout,
                    ),
                    label: const Text(
                      'Back to Login',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}