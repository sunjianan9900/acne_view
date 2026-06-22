import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryTeal = Color(0xFF49A685);
  static const Color softBackground = Color(0xFFF8F6F7);
  static const Color cardWhite = Colors.white;
  static const Color textPrimary = Color(0xFF2A2A2A);
  static const Color textSecondary = Color(0xFF8A8587);
  static const Color accentCoral = Color(0xFFE77784);
  static const Color softRose = Color(0xFFFFF2F5);
  static const Color brandPink = Color(0xFFE96A80);
  static const Color panelBorder = Color(0xFFF1E7EA);

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryTeal,
      brightness: Brightness.light,
      surface: softBackground,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: softBackground,
      textTheme: const TextTheme(
        headlineSmall: TextStyle(fontSize: 30, color: textPrimary),
        titleLarge: TextStyle(fontSize: 24, color: textPrimary),
        titleMedium: TextStyle(fontSize: 18, color: textPrimary),
        bodyMedium: TextStyle(fontSize: 14, color: textPrimary, height: 1.4),
        bodySmall: TextStyle(fontSize: 12, color: textSecondary, height: 1.4),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: softBackground,
        foregroundColor: textPrimary,
      ),
      cardTheme: CardThemeData(
        color: cardWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: panelBorder),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: brandPink,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: brandPink,
          side: const BorderSide(color: panelBorder),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: brandPink, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: brandPink,
        foregroundColor: Colors.white,
      ),
    );
  }
}
