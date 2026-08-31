import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Main background and surface color (Off-white)
  static const Color background = Color(0xFFF2F0EF);
  static const Color surface = Color(0xFFF2F0EF);

  // Vibrant accent and brand color (Deep Blue)
  static const Color primary = Color(0xFF245F73);


  // Grey for unselected states
  static const Color grey = Color(0xFFBBBDBC); // Original light grey

  // Financial colors
  static const Color income = Color(0xFF2E7D32); // Deep green
  static const Color expense = Color(0xFFD32F2F); // Deep red

  // Standardized semantic UI colors
  static const Color error = Color(0xFFD32F2F); // Semantic error
  static const Color white = Color(0xFFFFFFFF);
  static const Color transparent = Color(0x00000000);
  
  // Grey-scale variables
  static const Color surfaceLight = Color(0xFFFAFAFA); // Replaces grey.shade50
  static const Color divider = Color(0xFFEEEEEE); // Replaces grey.shade200
  static const Color border = Color(0xFFE0E0E0); // Replaces grey.shade300
  static const Color textMuted = Color(0xFF424242); // Replaces grey.shade800

  // Text colours
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF616161);

  // Reusable Color Palette
  static const List<String> colorPaletteHexes = [
    '#9E9E9E', // Grey
    '#245F73', // Primary Blue
    '#F44336', // Red
    '#E91E63', // Pink
    '#9C27B0', // Purple
    '#673AB7', // Deep Purple
    '#3F51B5', // Indigo
    '#03A9F4', // Light Blue
    '#00BCD4', // Cyan
    '#009688', // Teal
    '#4CAF50', // Green
    '#8BC34A', // Light Green
    '#CDDC39', // Lime
    '#FFEB3B', // Yellow
    '#FFC107', // Amber
    '#FF9800', // Orange
    '#FF5722', // Deep Orange
    '#795548', // Brown
    '#607D8B', // Blue Grey
  ];

  static Color getColorFromHex(String? hexString) {
    if (hexString == null || hexString.isEmpty) return AppColors.grey;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

class AppStyles {
  // Standardized padding for the main body of screens
  static const EdgeInsets screenPadding = EdgeInsets.all(24.0);
  
  // Standardized padding for slide-up modals
  static const EdgeInsets modalPadding = EdgeInsets.all(16.0);
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
        secondary: AppColors.primary,
        surface: AppColors.surface,
        error: AppColors.error,
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
