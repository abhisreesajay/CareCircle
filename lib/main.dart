import 'package:flutter/material.dart';
import 'services/messaging_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/user_model.dart';
import 'services/auth_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/elder/elder_home.dart';
import 'guards/caregiver_gateway.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Initialize Messaging BEFORE runApp
  MessagingService.setupBackgroundHandling();
  await MessagingService().initialize();

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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF164A63)),
        useMaterial3: true,
      ),
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
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const LoginScreen();
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
        );
      },
    );
  }
}
