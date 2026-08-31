import 'package:flutter/material.dart';

/// Centralized Color Palette & Material 3 Color Schemes for SoulSync.
abstract class AppColors {
  // Primary Palette Tokens (Sprint 1.2 Specification)
  static const Color primary = Color(0xFF7C5CFC);
  static const Color primaryDark = Color(0xFF5B38E0);
  static const Color primaryLight = Color(0xFF9B82FD);

  static const Color secondary = Color(0xFFA855F7);
  static const Color secondaryDark = Color(0xFF7E22CE);
  static const Color secondaryLight = Color(0xFFC084FC);

  static const Color accent = Color(0xFFFF6B9D);
  static const Color accentDark = Color(0xFFE0407B);
  static const Color accentLight = Color(0xFFFF94B9);

  // Background & Surface Tokens
  static const Color backgroundDark = Color(0xFF0F1115);
  static const Color surfaceDark = Color(0xFF1A1D24);
  static const Color surfaceDarkVariant = Color(0xFF242832);
  static const Color surfaceDarkElevated = Color(0xFF2C313E);

  static const Color backgroundLight = Color(0xFFF6F8FC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceLightVariant = Color(0xFFEEF2F9);
  static const Color surfaceLightElevated = Color(0xFFE2E8F4);

  // Feedback State Tokens
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Neutral Tokens
  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static const Color textMutedDark = Color(0xFF6B7280);

  static const Color textPrimaryLight = Color(0xFF111827);
  static const Color textSecondaryLight = Color(0xFF4B5563);
  static const Color textMutedLight = Color(0xFF9CA3AF);

  // Material 3 Dark ColorScheme
  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: primary,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFF322370),
    onPrimaryContainer: Color(0xFFE2DBFF),
    secondary: secondary,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFF4B1B75),
    onSecondaryContainer: Color(0xFFF3E8FF),
    tertiary: accent,
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFF6B1D3A),
    onTertiaryContainer: Color(0xFFFFD6E4),
    error: error,
    onError: Colors.white,
    surface: surfaceDark,
    onSurface: textPrimaryDark,
    surfaceContainerHighest: surfaceDarkVariant,
    onSurfaceVariant: textSecondaryDark,
    outline: Color(0xFF374151),
    outlineVariant: Color(0xFF1F2937),
    shadow: Colors.black,
  );

  // Material 3 Light ColorScheme
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFECE7FF),
    onPrimaryContainer: Color(0xFF241261),
    secondary: secondary,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFF5E8FF),
    onSecondaryContainer: Color(0xFF3B0B5E),
    tertiary: accent,
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFFFE0EC),
    onTertiaryContainer: Color(0xFF520E27),
    error: error,
    onError: Colors.white,
    surface: surfaceLight,
    onSurface: textPrimaryLight,
    surfaceContainerHighest: surfaceLightVariant,
    onSurfaceVariant: textSecondaryLight,
    outline: Color(0xFFD1D5DB),
    outlineVariant: Color(0xFFE5E7EB),
    shadow: Color(0x1F000000),
  );
}
