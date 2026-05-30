import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const Color primary = Color(0xFF4CAF50);
  static const Color dark = Color(0xFF101719);
  static const Color surface = Color(0xFF1A2326);
  static const Color accentBlue = Color(0xFF42A5F5);

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
      fontFamily: 'Segoe UI',
      textTheme: ThemeData.dark().textTheme.apply(bodyColor: Colors.white),
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
