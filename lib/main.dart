import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  runApp(const CareCircleApp());
}

class CareCircleApp extends StatelessWidget {
  const CareCircleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CareCircle',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.caregiverTheme,
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

        if (snapshot.hasData) {
          return RoleRouter(uid: snapshot.data!.uid);
        }

        return const LoginScreen();
      },
    );
  }
}

class RoleRouter extends StatelessWidget {
  final String uid;
  const RoleRouter({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

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
        }

        return const LoginScreen();
      },
    );
  }
}
