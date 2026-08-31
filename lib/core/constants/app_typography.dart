import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized Typography tokens using Plus Jakarta Sans for SoulSync.
abstract class AppTypography {
  static TextStyle get displayLarge => GoogleFonts.plusJakartaSans(
        fontSize: 32.0,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      );

  static TextStyle get displayMedium => GoogleFonts.plusJakartaSans(
        fontSize: 28.0,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.25,
      );

  static TextStyle get headlineLarge => GoogleFonts.plusJakartaSans(
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get headlineMedium => GoogleFonts.plusJakartaSans(
        fontSize: 20.0,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get titleLarge => GoogleFonts.plusJakartaSans(
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get titleMedium => GoogleFonts.plusJakartaSans(
        fontSize: 16.0,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get bodyLarge => GoogleFonts.plusJakartaSans(
        fontSize: 16.0,
        fontWeight: FontWeight.normal,
      );

  static TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
        fontSize: 14.0,
        fontWeight: FontWeight.normal,
      );

  static TextStyle get bodySmall => GoogleFonts.plusJakartaSans(
        fontSize: 12.0,
        fontWeight: FontWeight.normal,
      );

  static TextStyle get labelLarge => GoogleFonts.plusJakartaSans(
        fontSize: 14.0,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.1,
      );

  static TextStyle get labelMedium => GoogleFonts.plusJakartaSans(
        fontSize: 12.0,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      );

  static TextStyle get caption => GoogleFonts.plusJakartaSans(
        fontSize: 10.0,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.4,
      );
}
