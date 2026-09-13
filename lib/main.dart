import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'screens/elder/elder_home.dart';
import 'screens/elder/check_in_screen.dart';
import 'screens/elder/voice_check_in_screen.dart';

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
      debugShowCheckedModeBanner: false,
      title: 'CareCircle',

      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF164A63),
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F8FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF164A63),
          foregroundColor: Colors.white,
          centerTitle: false,
        ),
      ),

      home: const ElderHome(),

      routes: {
        '/checkin': (context) => const CheckInScreen(),
        '/voice-checkin': (context) => const VoiceCheckInScreen(),
      },
    );
  }
}