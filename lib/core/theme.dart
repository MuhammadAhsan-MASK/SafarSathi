import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors from the Video
  static const Color primaryPurple = Color(0xFF6A1B9A);
  static const Color secondaryPink = Color(0xFFE91E63);
  static const Color accentBlue = Color(0xFF2196F3);
  static const Color surfaceColor = Colors.white;
  static const Color backgroundColor = Color(0xFFF5F5F7);
  static const Color errorColor = Color(0xFFD32F2F);

  // Gradient definitions
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryPurple, Color(0xFF9C27B0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentBlue, Color(0xFF03A9F4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Category Colors (Refined)
  static const Color hotelColor = Color(0xFF2196F3);      // Blue
  static const Color foodColor = Color(0xFFFF9800);       // Orange
  static const Color transportColor = Color(0xFF4CAF50);  // Green
  static const Color attractionColor = Color(0xFF9C27B0); // Purple

  // Subtle Backgrounds (Glass-like or soft)
  static const Color hotelBg = Color(0xFFE3F2FD);
  static const Color foodBg = Color(0xFFFFF3E0);
  static const Color transportBg = Color(0xFFE8F5E9);
  static const Color attractionBg = Color(0xFFF3E5F5);

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryPurple,
      primary: primaryPurple,
      secondary: secondaryPink,
      surface: surfaceColor,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black87,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(), // Switched to Poppins for a more modern look
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 2,
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withOpacity(0.9),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryPurple, width: 2),
      ),
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      surfaceTintColor: Colors.white,
    ),
  );
}
