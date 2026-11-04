import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color forest = Color(0xFF0F3D2E);
  static const Color teal = Color(0xFF1B6B5A);
  static const Color mint = Color(0xFF3D9B84);
  static const Color sand = Color(0xFFF3EDE3);
  static const Color ink = Color(0xFF14201C);
  static const Color softInk = Color(0xFF4A5A54);
  static const Color income = Color(0xFF1B6B5A);
  static const Color expense = Color(0xFFB54A3C);
  static const Color pending = Color(0xFFB8860B);
  static const Color failed = Color(0xFF8B2E2E);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ColorScheme.fromSeed(
      seedColor: AppColors.teal,
      brightness: Brightness.light,
      primary: AppColors.forest,
      secondary: AppColors.mint,
      surface: AppColors.sand,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: base,
      scaffoldBackgroundColor: AppColors.sand,
      fontFamily: 'Georgia',
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.ink,
        titleTextStyle: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
      ),
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          fontFamily: 'Georgia',
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
          fontSize: 32,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Georgia',
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
          fontSize: 24,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Georgia',
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
          fontSize: 18,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Georgia',
          color: AppColors.ink,
          fontSize: 16,
          height: 1.4,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Georgia',
          color: AppColors.softInk,
          fontSize: 14,
          height: 1.4,
        ),
        labelLarge: TextStyle(
          fontFamily: 'Georgia',
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.forest,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.7),
        selectedColor: AppColors.teal.withValues(alpha: 0.2),
        side: BorderSide(color: AppColors.teal.withValues(alpha: 0.3)),
        labelStyle: const TextStyle(fontFamily: 'Georgia', fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  static ThemeData get dark {
    final base = ColorScheme.fromSeed(
      seedColor: AppColors.mint,
      brightness: Brightness.dark,
      primary: AppColors.mint,
      secondary: AppColors.teal,
      surface: const Color(0xFF0E1714),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: base,
      scaffoldBackgroundColor: const Color(0xFF0A1210),
      fontFamily: 'Georgia',
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFFE8F0EC),
      ),
      textTheme: light.textTheme.apply(
        bodyColor: const Color(0xFFE8F0EC),
        displayColor: const Color(0xFFE8F0EC),
      ),
    );
  }
}
