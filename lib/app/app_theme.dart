import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const Color primary = Color(0xFF4CAF50);
  static const Color dark = Color(0xFF101719);
  static const Color surface = Color(0xFF1A2326);
  static const Color accentBlue = Color(0xFF42A5F5);
  static const String headingFont = 'Poppins';
  static const String bodyFont = 'Poppins';

  static ThemeData darkTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
      primary: primary,
      surface: surface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: dark,
      fontFamily: bodyFont,
      textTheme: ThemeData.dark().textTheme.copyWith(
        displayLarge: const TextStyle(fontFamily: headingFont, color: Colors.white),
        displayMedium: const TextStyle(fontFamily: headingFont, color: Colors.white),
        displaySmall: const TextStyle(fontFamily: headingFont, color: Colors.white),
        headlineLarge: const TextStyle(fontFamily: headingFont, color: Colors.white),
        headlineMedium: const TextStyle(fontFamily: headingFont, color: Colors.white),
        headlineSmall: const TextStyle(fontFamily: headingFont, color: Colors.white),
        titleLarge: const TextStyle(fontFamily: headingFont, color: Colors.white),
        titleMedium: const TextStyle(fontFamily: bodyFont, color: Colors.white),
        titleSmall: const TextStyle(fontFamily: bodyFont, color: Colors.white),
        bodyLarge: const TextStyle(fontFamily: bodyFont, color: Colors.white),
        bodyMedium: const TextStyle(fontFamily: bodyFont, color: Colors.white),
        bodySmall: const TextStyle(fontFamily: bodyFont, color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.07),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
