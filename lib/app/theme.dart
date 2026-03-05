import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color lightBackground = Color(0xFFF5F6FA);
  static const Color lightCard = Colors.white;
  static const Color lightPrimary = Color(0xFF6366F1);
  static const Color lightText = Colors.black;
  static const Color lightSecondaryText = Color(0xFF6B7280);

  static const Color darkBackground = Color(0xFF1C2333);
  static const Color darkCard = Color(0xFF2A3447);
  static const Color darkPrimary = Color(0xFFF5C842);
  static const Color darkText = Colors.white;
  static const Color darkSecondaryText = Color(0xFF8A97B0);

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBackground,
    textTheme: GoogleFonts.poppinsTextTheme().apply(
      bodyColor: lightText,
      displayColor: lightText,
    ),
    colorScheme: const ColorScheme.light(
      primary: lightPrimary,
      secondary: lightPrimary,
      background: lightBackground,
      surface: lightCard,
      onPrimary: Colors.white,
      onSurface: Colors.black,
    ),
    cardColor: lightCard,
    dividerColor: Colors.grey.shade300,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightPrimary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: lightBackground,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    checkboxTheme: const CheckboxThemeData(
      fillColor: MaterialStatePropertyAll(lightPrimary),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackground,
    textTheme: GoogleFonts.poppinsTextTheme().apply(
      bodyColor: darkText,
      displayColor: darkText,
    ),
    colorScheme: const ColorScheme.dark(
      primary: darkPrimary,
      secondary: darkPrimary,
      background: darkBackground,
      surface: darkCard,
      onPrimary: Colors.black,
      onSurface: Colors.white,
    ),
    cardColor: darkCard,
    dividerColor: Colors.white24,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkPrimary,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackground,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    checkboxTheme: const CheckboxThemeData(
      fillColor: MaterialStatePropertyAll(darkPrimary),
    ),
  );
}
