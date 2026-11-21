import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// BlockCore Studio — Linear + Phantom Hybrid Design System
/// High-density developer console tokens, strictly free & open-source.
class ConsoleTheme {
  ConsoleTheme._();

  // Surface & Neutral Palette (Linear Zinc / Slate)
  static const Color background = Color(0xFF090C0E);
  static const Color cardSurface = Color(0xFF0F1419);
  static const Color cardSurfaceElevated = Color(0xFF141A20);
  static const Color cardBorder = Color(0x14FFFFFF); // 1px subtle white/0.08
  static const Color cardBorderActive = Color(0x3353F2C2); // subtle mint glow

  // Status & Telemetry Accents
  static const Color accentMint =
      Color(0xFF53F2C2); // Verified, Valid, Dürüst Node
  static const Color accentMintBg = Color(0xFF0F2620);
  static const Color accentRed =
      Color(0xFFFF4D4D); // Corrupted, Sahte İmza, Saldırgan
  static const Color accentRedBg = Color(0xFF2C1215);
  static const Color accentAmber =
      Color(0xFFFFC857); // Madencilik, Mempool, PoW
  static const Color accentAmberBg = Color(0xFF2B220E);
  static const Color textMuted = Color(0xFF7E8B96);
  static const Color textSecondary = Color(0xFFA5B2BC);

  // Typography (Inter + JetBrains Mono)
  static TextStyle labelTiny({Color color = textMuted}) {
    return GoogleFonts.inter(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
      color: color,
    );
  }

  static TextStyle titleMedium({Color color = Colors.white}) {
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
      color: color,
    );
  }

  static TextStyle monoMetrics({
    Color color = Colors.white,
    double size = 13,
    FontWeight weight = FontWeight.w600,
  }) {
    return GoogleFonts.jetBrainsMono(
      fontSize: size,
      fontWeight: weight,
      color: color,
      fontFeatures: const [FontFeature.tabularFigures()],
      letterSpacing: -0.3,
    );
  }

  static TextStyle monoHash({Color color = accentMint, double size = 11}) {
    return GoogleFonts.jetBrainsMono(
      fontSize: size,
      fontWeight: FontWeight.w500,
      color: color,
      letterSpacing: -0.2,
    );
  }

  // Linear / Phantom Card Box Decoration
  static BoxDecoration cardDecoration({
    Color bg = cardSurface,
    Color border = cardBorder,
    double radius = 8,
  }) {
    return BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: border, width: 1),
    );
  }

  // ThemeData Definition
  static ThemeData get themeData {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: accentMint,
        surface: cardSurface,
        onSurface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: cardBorder,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
