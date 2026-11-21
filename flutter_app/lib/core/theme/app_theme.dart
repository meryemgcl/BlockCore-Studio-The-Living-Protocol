import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RevolutTheme {
  RevolutTheme._();

  // Gradients & Backgrounds
  static const Color darkBackground = Color(0xFF090D16);
  static const Color cardSurface = Color(0xFF131927);
  static const Color cardSurfaceLight = Color(0xFF1A2234);
  static const Color royalBlue = Color(0xFF0A3FE2);
  static const Color cobaltBlue = Color(0xFF0628A6);

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0D47E8),
      Color(0xFF0A2B99),
      Color(0xFF090D16),
    ],
    stops: [0.0, 0.45, 0.85],
  );

  // Accents
  static const Color accentGreen = Color(0xFF00D563);
  static const Color accentRed = Color(0xFFFF453A);
  static const Color accentCyan = Color(0xFF00E5FF);
  static const Color pillBackground = Color(0x33FFFFFF);

  // Text Styles
  static TextStyle heroBalance = GoogleFonts.inter(
    fontSize: 42,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: -1.0,
  );

  static TextStyle titleMedium = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: -0.3,
  );

  static TextStyle body = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Colors.white70,
  );

  static TextStyle caption = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Colors.white54,
  );

  static TextStyle monoNumeric = GoogleFonts.jetBrainsMono(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: royalBlue,
        surface: cardSurface,
        onSurface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
