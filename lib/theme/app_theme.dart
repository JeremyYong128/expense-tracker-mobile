import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Main background and surface color (Off-white)
  static const Color background = Color(0xFFF2F0EF);
  static const Color surface = Color(0xFFF2F0EF);

  // Vibrant accent and brand color (Deep Blue)
  static const Color primary = Color(0xFF245F73);

  // Accent color for expenses/warnings (Brown)
  static const Color accent = Color(0xFF733E24);

  // Grey for unselected states
  static const Color grey = Color(0xFFBBBDBC); // Original light grey

  // Financial colors
  static const Color income = Color(0xFF2E7D32); // Deep green
  static const Color expense = Color(0xFFD32F2F); // Deep red

  // Text colours
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF616161);
}

class AppStyles {
  // Standardized padding for the main body of screens
  static const EdgeInsets screenPadding = EdgeInsets.all(24.0);
}

class AppTheme {
  static ThemeData get lightTheme {
    final base = ThemeData.light();

    return ThemeData(
      brightness: Brightness.light,
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,

      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        error: AppColors.accent,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors
            .white, // Pure white makes the nav bar pop against the off-white background
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey,
        elevation: 10,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize: 12.0),
        unselectedLabelStyle: TextStyle(fontSize: 12.0),
      ),
    );
  }
}
