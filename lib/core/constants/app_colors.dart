import 'package:flutter/material.dart';

/// Centralized Color Palette & Material 3 Color Schemes for SoulSync.
abstract class AppColors {
  // Primary Palette Tokens (Dark Blood Crimson)
  static const Color primary = Color(0xFFD3122A);
  static const Color primaryDark = Color(0xFF8B0000);
  static const Color primaryLight = Color(0xFFFF2A4B);

  static const Color secondary = Color(0xFF8B1528);
  static const Color secondaryDark = Color(0xFF5A0B17);
  static const Color secondaryLight = Color(0xFFA8263D);

  static const Color accent = Color(0xFFFF4D6D);
  static const Color accentDark = Color(0xFFC7153B);
  static const Color accentLight = Color(0xFFFF758F);

  // Background & Surface Tokens (Obsidian Noir & Smoky Wine)
  static const Color backgroundDark = Color(0xFF080607);
  static const Color surfaceDark = Color(0xFF140D10);
  static const Color surfaceDarkVariant = Color(0xFF1C1317);
  static const Color surfaceDarkElevated = Color(0xFF261920);

  static const Color backgroundLight = Color(0xFFFBF8F8);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceLightVariant = Color(0xFFF5EBEB);
  static const Color surfaceLightElevated = Color(0xFFEEDCDC);

  // Feedback State Tokens
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Neutral Tokens
  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFF9E979A);
  static const Color textMutedDark = Color(0xFF6B6366);

  static const Color textPrimaryLight = Color(0xFF1C1317);
  static const Color textSecondaryLight = Color(0xFF4B4245);
  static const Color textMutedLight = Color(0xFF9E979A);

  // Material 3 Dark ColorScheme
  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: primary,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFF4D0510),
    onPrimaryContainer: Color(0xFFFFD9DF),
    secondary: secondary,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFF3B0710),
    onSecondaryContainer: Color(0xFFFFD9E2),
    tertiary: accent,
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFF5A0B1A),
    onTertiaryContainer: Color(0xFFFFD8E0),
    error: error,
    onError: Colors.white,
    surface: surfaceDark,
    onSurface: textPrimaryDark,
    surfaceContainerHighest: surfaceDarkVariant,
    onSurfaceVariant: textSecondaryDark,
    outline: Color(0xFF3A242B),
    outlineVariant: Color(0xFF25151B),
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
