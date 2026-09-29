import 'package:flutter/material.dart';

class ElderColors {
  static const Color primary = Color(0xFF000000);         // Pure Black
  static const Color secondary = Color(0xFFFF6B00);       // Bright Burnt Orange
  static const Color accent = Color(0xFFFFB81C);          // Bright Yellow-Orange
  static const Color success = Color(0xFF00AA00);         // Bright Green
  static const Color critical = Color(0xFFCC0000);        // Bright Red (SOS)
  static const Color background = Color(0xFFFFFFFF);      // Pure White
  static const Color surface = Color(0xFFFFFFFF);
  static const Color text = Color(0xFF000000);
}

class CaregiverColors {
  static const Color duskBlue = Color(0xFF355070);        // Twilight Blue
  static const Color dustyLavender = Color(0xFF6D597A);   // Neutral / Cards
  static const Color rosewood = Color(0xFFB56576);        // Accent / Highlights
  static const Color lightCoral = Color(0xFFE56B6F);      // Secondary Alerts
  static const Color lightBronze = Color(0xFFEAAC8B);     // Warm Surfaces
  static const Color background = Color(0xFFF7F5F8);
  static const Color surface = Color(0xFFFFFFFF);
}

class AdminColors {
  static const Color primary = Color(0xFF0F172A);         // Deep Midnight Slate
  static const Color accent = Color(0xFF2563EB);          // Enterprise Cobalt Blue
  static const Color secondary = Color(0xFF475569);       // Steel Gray
  static const Color cyanSignal = Color(0xFF0891B2);      // Metrics Highlight
  static const Color background = Color(0xFFF8FAFC);      // Enterprise Canvas
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0);
}

class AppTheme {
  static ThemeData get elderTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: ElderColors.primary,
        secondary: ElderColors.secondary,
        surface: ElderColors.surface,
        error: ElderColors.critical,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: ElderColors.text,
      ),
      scaffoldBackgroundColor: ElderColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: ElderColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: ElderColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: ElderColors.primary, width: 2.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ElderColors.secondary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 64),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontSize: 20, color: ElderColors.text, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(fontSize: 24, color: ElderColors.text, fontWeight: FontWeight.bold),
      ),
    );
  }

  static ThemeData get caregiverTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: CaregiverColors.duskBlue,
        secondary: CaregiverColors.dustyLavender,
        tertiary: CaregiverColors.rosewood,
        surface: CaregiverColors.surface,
        error: CaregiverColors.lightCoral,
        onPrimary: Colors.white,
        onSurface: CaregiverColors.duskBlue,
      ),
      scaffoldBackgroundColor: CaregiverColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: CaregiverColors.duskBlue,
        foregroundColor: Colors.white,
        elevation: 1,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: CaregiverColors.surface,
        elevation: 2,
        shadowColor: CaregiverColors.duskBlue.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: CaregiverColors.lightBronze, width: 0.8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CaregiverColors.duskBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  static ThemeData get adminTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AdminColors.primary,
        secondary: AdminColors.accent,
        surface: AdminColors.surface,
        error: const Color(0xFFEF4444),
        onPrimary: Colors.white,
        onSurface: AdminColors.primary,
      ),
      scaffoldBackgroundColor: AdminColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AdminColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: AdminColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AdminColors.border, width: 1),
        ),
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: AdminColors.primary,
        selectedIconTheme: IconThemeData(color: Colors.white, size: 24),
        unselectedIconTheme: IconThemeData(color: Color(0xFF94A3B8), size: 22),
        selectedLabelTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        unselectedLabelTextStyle: TextStyle(color: Color(0xFF94A3B8)),
        indicatorColor: AdminColors.accent,
      ),
    );
  }
}
