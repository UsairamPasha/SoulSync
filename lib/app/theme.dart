import 'package:flutter/material.dart';

import 'package:soulsync/core/constants/app_colors.dart';
import 'package:soulsync/core/constants/app_radius.dart';
import 'package:soulsync/core/constants/app_typography.dart';
import 'package:soulsync/core/constants/theme_extensions.dart';

/// Centralized Material 3 Design System & Theme Configuration for SoulSync.
abstract class AppTheme {
  /// Centralized Light Theme
  static ThemeData get lightTheme {
    return _buildTheme(
      AppColors.lightColorScheme,
      AppColors.backgroundLight,
      SoulSyncCustomColors.light,
    );
  }

  /// Centralized Dark Theme
  static ThemeData get darkTheme {
    return _buildTheme(
      AppColors.darkColorScheme,
      AppColors.backgroundDark,
      SoulSyncCustomColors.dark,
    );
  }

  static ThemeData _buildTheme(
    ColorScheme colorScheme,
    Color scaffoldBg,
    SoulSyncCustomColors customColors,
  ) {
    final textTheme = TextTheme(
      displayLarge:
          AppTypography.displayLarge.copyWith(color: colorScheme.onSurface),
      displayMedium:
          AppTypography.displayMedium.copyWith(color: colorScheme.onSurface),
      headlineLarge:
          AppTypography.headlineLarge.copyWith(color: colorScheme.onSurface),
      headlineMedium:
          AppTypography.headlineMedium.copyWith(color: colorScheme.onSurface),
      titleLarge:
          AppTypography.titleLarge.copyWith(color: colorScheme.onSurface),
      titleMedium:
          AppTypography.titleMedium.copyWith(color: colorScheme.onSurface),
      bodyLarge: AppTypography.bodyLarge.copyWith(color: colorScheme.onSurface),
      bodyMedium:
          AppTypography.bodyMedium.copyWith(color: colorScheme.onSurface),
      bodySmall:
          AppTypography.bodySmall.copyWith(color: colorScheme.onSurfaceVariant),
      labelLarge:
          AppTypography.labelLarge.copyWith(color: colorScheme.onSurface),
      labelMedium: AppTypography.labelMedium
          .copyWith(color: colorScheme.onSurfaceVariant),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBg,
      textTheme: textTheme,
      extensions: [customColors],

      // AppBar Theme
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: scaffoldBg,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: customColors.cardBackground,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.borderLG,
        ),
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.borderMD,
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // Filled Button Theme
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.borderMD,
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.borderMD,
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // InputDecoration / TextField Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: const OutlineInputBorder(
          borderRadius: AppRadius.borderMD,
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.borderMD,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderMD,
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderMD,
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderMD,
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
        ),
      ),

      // SnackBar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.borderMD,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
