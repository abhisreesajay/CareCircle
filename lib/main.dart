import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'screens/caregiver_dashboard.dart';

const String configuredElderId = String.fromEnvironment('ELDER_ID');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF738F52),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F9F3),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF738F52),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 2,
        ),
        useMaterial3: true,
      ),
      home: configuredElderId.isEmpty
          ? const ElderIdRequiredScreen()
          : const CaregiverDashboard(
              elderId: configuredElderId,
            ),
    );
  }
}

class ElderIdRequiredScreen extends StatelessWidget {
  const ElderIdRequiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Elder ID is not configured.\n\n'
            'Run the app with:\n'
            '--dart-define=ELDER_ID=<elder-id>',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}