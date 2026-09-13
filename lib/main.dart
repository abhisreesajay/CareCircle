import 'package:flutter/material.dart';

import 'screens/elder/elder_home.dart';
import 'screens/elder/check_in_screen.dart';
import 'screens/elder/voice_check_in_screen.dart';

void main() {
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

        scaffoldBackgroundColor:
            const Color(0xFFF4F8FA),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF164A63),
          foregroundColor: Colors.white,
          centerTitle: false,
        ),
      ),

      // First screen shown when the app starts
      home: const ElderHome(),

      // Navigation routes for Elder application
      routes: {
        '/checkin': (context) =>
            const CheckInScreen(),

        '/voice-checkin': (context) =>
            const VoiceCheckInScreen(),
      },
    );
  }
}
