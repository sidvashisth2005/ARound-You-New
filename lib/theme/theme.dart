import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Premium elegant color palette
  static const Color primaryDark = Color(0xFF2F4156);    // Deep blue-gray
  static const Color secondaryBlue = Color(0xFF567C8D);  // Medium blue
  static const Color warmCream = Color(0xFFF5EFEB);      // Warm cream
  static const Color lightBlue = Color(0xFFC8D9E6);      // Light blue
  static const Color pureWhite = Color(0xFFFFFFFF);      // Pure white
  
  // Premium accent colors
  static const Color accentGold = Color(0xFFD4AF37);     // Elegant gold
  static const Color subtleGray = Color(0xFFE8E8E8);    // Subtle gray
  static const Color darkAccent = Color(0xFF1A2634);    // Darker accent
  static const Color premiumBlue = Color(0xFF4A90E2);   // Premium blue
  static const Color softMint = Color(0xFFE8F5E8);      // Soft mint

  // Define the premium elegant theme data
  static final ThemeData elegantTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryDark,
    scaffoldBackgroundColor: pureWhite,
    
    // Enhanced color scheme with premium colors
    colorScheme: const ColorScheme.light(
      primary: primaryDark,
      secondary: secondaryBlue,
      tertiary: accentGold,
      surface: pureWhite,
      onPrimary: pureWhite,
      onSecondary: pureWhite,
      onTertiary: primaryDark,
      onSurface: primaryDark,
      error: Color(0xFFE57373),
      onError: pureWhite,
      outline: lightBlue,
      outlineVariant: subtleGray,
    ),

    // Premium text theme with sophisticated typography
    textTheme: GoogleFonts.interTextTheme(
      ThemeData.light().textTheme,
    ).copyWith(
      bodyLarge: const TextStyle(
        color: primaryDark, 
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.6,
      ),
      bodyMedium: const TextStyle(
        color: primaryDark, 
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      headlineLarge: const TextStyle(
        fontWeight: FontWeight.w700, 
        color: primaryDark, 
        letterSpacing: -0.5,
        fontSize: 32,
        height: 1.2,
      ),
      headlineMedium: const TextStyle(
        fontWeight: FontWeight.w600, 
        color: primaryDark, 
        letterSpacing: -0.25,
        fontSize: 28,
        height: 1.3,
      ),
      titleLarge: const TextStyle(
        color: primaryDark, 
        fontWeight: FontWeight.w600,
        fontSize: 22,
        letterSpacing: -0.15,
        height: 1.4,
      ),
      titleMedium: const TextStyle(
        color: primaryDark, 
        fontWeight: FontWeight.w500,
        fontSize: 18,
        height: 1.4,
      ),
      labelLarge: const TextStyle(
        color: primaryDark, 
        fontWeight: FontWeight.w500,
        fontSize: 14,
        height: 1.3,
      ),
    ),

    // Premium app bar theme
    appBarTheme: AppBarTheme(
      backgroundColor: pureWhite,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(
        color: primaryDark,
        size: 24,
      ),
      titleTextStyle: GoogleFonts.inter(
        color: primaryDark,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.15,
      ),
      surfaceTintColor: pureWhite,
      shadowColor: primaryDark.withValues(alpha: 0.08),
    ),

    // Premium elevated button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryDark,
        foregroundColor: pureWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          letterSpacing: 0.1,
        ),
        elevation: 4,
        shadowColor: primaryDark.withValues(alpha: 0.3),
      ),
    ),

    // Premium input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: warmCream,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: lightBlue, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: secondaryBlue, width: 2.5),
      ),
      labelStyle: const TextStyle(
        color: secondaryBlue,
        fontWeight: FontWeight.w500,
        fontSize: 15,
      ),
      hintStyle: TextStyle(
        color: primaryDark.withValues(alpha: 0.5),
        fontWeight: FontWeight.w400,
        fontSize: 15,
      ),
      floatingLabelStyle: const TextStyle(
        color: secondaryBlue,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
    ),

    // Premium card theme
    cardTheme: CardThemeData(
      color: pureWhite,
      elevation: 8,
      shadowColor: primaryDark.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // Premium floating action button theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: secondaryBlue,
      foregroundColor: pureWhite,
      elevation: 8,
      shape: CircleBorder(),
    ),

    // Premium bottom navigation theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: pureWhite,
      selectedItemColor: primaryDark,
      unselectedItemColor: subtleGray,
      type: BottomNavigationBarType.fixed,
      elevation: 16,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
    ),
  );

  // Premium gradient definitions
  static const LinearGradient elegantGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [pureWhite, softMint, warmCream],
    stops: [0.0, 0.4, 1.0],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryDark, secondaryBlue],
  );

  static const LinearGradient subtleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [warmCream, pureWhite],
  );

  static final LinearGradient premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [pureWhite, lightBlue.withValues(alpha: 0.3), warmCream],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentGold, Color(0xFFF4D03F)],
  );

  // Premium container decorations
  static BoxDecoration elegantCardDecoration = BoxDecoration(
    color: pureWhite,
    borderRadius: BorderRadius.circular(28),
    border: Border.all(color: lightBlue.withValues(alpha: 0.2), width: 1),
    boxShadow: [
      BoxShadow(
        color: primaryDark.withValues(alpha: 0.08),
        blurRadius: 24,
        spreadRadius: 0,
        offset: const Offset(0, 8),
      ),
      BoxShadow(
        color: primaryDark.withValues(alpha: 0.04),
        blurRadius: 48,
        spreadRadius: 0,
        offset: const Offset(0, 16),
      ),
    ],
  );

  static BoxDecoration glassPanelDecoration = BoxDecoration(
    color: pureWhite.withValues(alpha: 0.95),
    borderRadius: BorderRadius.circular(28),
    border: Border.all(color: lightBlue.withValues(alpha: 0.15), width: 1),
    boxShadow: [
      BoxShadow(
        color: primaryDark.withValues(alpha: 0.06),
        blurRadius: 32,
        spreadRadius: 0,
        offset: const Offset(0, 12),
      ),
      BoxShadow(
        color: primaryDark.withValues(alpha: 0.03),
        blurRadius: 64,
        spreadRadius: 0,
        offset: const Offset(0, 24),
      ),
    ],
  );

  static BoxDecoration premiumCardDecoration = BoxDecoration(
    color: pureWhite,
    borderRadius: BorderRadius.circular(32),
    border: Border.all(color: lightBlue.withValues(alpha: 0.25), width: 1.5),
    boxShadow: [
      BoxShadow(
        color: primaryDark.withValues(alpha: 0.1),
        blurRadius: 32,
        spreadRadius: 0,
        offset: const Offset(0, 12),
      ),
      BoxShadow(
        color: primaryDark.withValues(alpha: 0.05),
        blurRadius: 64,
        spreadRadius: 0,
        offset: const Offset(0, 24),
      ),
    ],
  );

  // Premium shadow effects
  static List<BoxShadow> subtleShadows = [
    BoxShadow(
      color: primaryDark.withValues(alpha: 0.08),
      blurRadius: 24,
      spreadRadius: 0,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: primaryDark.withValues(alpha: 0.04),
      blurRadius: 48,
      spreadRadius: 0,
      offset: const Offset(0, 16),
    ),
  ];

  static List<BoxShadow> cardShadows = [
    BoxShadow(
      color: primaryDark.withValues(alpha: 0.08),
      blurRadius: 20,
      spreadRadius: 0,
      offset: const Offset(0, 6),
    ),
    BoxShadow(
      color: primaryDark.withValues(alpha: 0.04),
      blurRadius: 40,
      spreadRadius: 0,
      offset: const Offset(0, 12),
    ),
  ];

  static List<BoxShadow> premiumShadows = [
    BoxShadow(
      color: primaryDark.withValues(alpha: 0.12),
      blurRadius: 32,
      spreadRadius: 0,
      offset: const Offset(0, 12),
    ),
    BoxShadow(
      color: primaryDark.withValues(alpha: 0.06),
      blurRadius: 64,
      spreadRadius: 0,
      offset: const Offset(0, 24),
    ),
  ];

  // Premium button styles
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryDark,
    foregroundColor: pureWhite,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
    textStyle: GoogleFonts.inter(
      fontWeight: FontWeight.w600,
      fontSize: 16,
      letterSpacing: 0.2,
    ),
    elevation: 6,
    shadowColor: primaryDark.withValues(alpha: 0.4),
  );

  static ButtonStyle secondaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: secondaryBlue,
    foregroundColor: pureWhite,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
    textStyle: GoogleFonts.inter(
      fontWeight: FontWeight.w600,
      fontSize: 16,
      letterSpacing: 0.2,
    ),
    elevation: 4,
    shadowColor: secondaryBlue.withValues(alpha: 0.3),
  );

  static ButtonStyle outlineButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: primaryDark,
    side: const BorderSide(color: primaryDark, width: 2),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
    textStyle: GoogleFonts.inter(
      fontWeight: FontWeight.w600,
      fontSize: 16,
      letterSpacing: 0.2,
    ),
  );
}
