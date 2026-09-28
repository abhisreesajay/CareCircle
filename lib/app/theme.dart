import 'package:flutter/material.dart';

class ElderColors {
  static const Color primary = Color(0xFF000000);
  static const Color secondary = Color(0xFFFF6B00);
  static const Color accent = Color(0xFFFFB81C);
  static const Color success = Color(0xFF00AA00);
  static const Color critical = Color(0xFFCC0000);

  static const Color background = Colors.white;
  static const Color text = Colors.black;
  static const Color mutedText = Color(0xFF666666);
  static const Color border = Color(0xFFE5E5E5);
}

ThemeData elderTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: ElderColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: ElderColors.secondary,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: ElderColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ElderColors.secondary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(12),
          ),
        ),
      ),
    ),
  );
}