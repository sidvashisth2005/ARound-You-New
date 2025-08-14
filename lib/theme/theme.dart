import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Define the core colors for the cyberpunk theme
  static const Color primaryColor = Color(0xFF00FFFF); // Cyan
  static const Color accentColor = Color(0xFFF800FF); // Magenta
  static const Color backgroundColor = Color(0xFF0A0A1A); // Very dark blue
  static const Color surfaceColor = Color(0xFF1A1A2A); // Dark blue surface
  static const Color textColor = Color(0xFFE0E0E0);
  static const Color errorColor = Color(0xFFFF4444);

  // Define the dark theme data
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    
    // Define the color scheme
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: accentColor,
      background: backgroundColor,
      surface: surfaceColor,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onBackground: textColor,
      onSurface: textColor,
      error: errorColor,
      onError: Colors.white,
    ),

    // Define the text theme using Google Fonts for a futuristic feel
    textTheme: GoogleFonts.orbitronTextTheme(
      ThemeData.dark().textTheme,
    ).copyWith(
      bodyLarge: const TextStyle(color: textColor, fontSize: 16),
      bodyMedium: const TextStyle(color: textColor, fontSize: 14),
      headlineLarge: const TextStyle(fontWeight: FontWeight.bold, color: primaryColor, letterSpacing: 1.2),
      headlineMedium: const TextStyle(fontWeight: FontWeight.bold, color: primaryColor, letterSpacing: 1.1),
      titleLarge: const TextStyle(color: textColor, fontWeight: FontWeight.bold),
      labelLarge: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
    ),

    // Define the app bar theme
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: primaryColor),
      titleTextStyle: GoogleFonts.orbitron(
        color: primaryColor,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),

    // Define the elevated button theme for primary actions
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: const BorderSide(color: primaryColor),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        textStyle: GoogleFonts.orbitron(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        shadowColor: primaryColor.withOpacity(0.5),
        elevation: 8,
      ),
    ),

    // Define the input decoration theme for text fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor.withOpacity(0.8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: primaryColor.withOpacity(0.3), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      labelStyle: TextStyle(color: accentColor.withOpacity(0.8)),
      hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
    ),
  );
}
