import 'package:flutter/material.dart';
import 'package:soulsync/core/constants/app_radius.dart';
import 'package:soulsync/core/constants/app_spacing.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';

/// Centralized Reusable Snackbar System for SoulSync.
abstract class AppSnackBars {
  static void _showCustomSnackBar({
    required BuildContext context,
    required String message,
    required Color backgroundColor,
    required Color foregroundColor,
    required IconData icon,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderMD),
        content: Row(
          children: [
            Icon(icon, color: foregroundColor, size: 20),
            AppSpacing.hGapMD,
            Expanded(
              child: Text(
                message,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Success Snackbar
  static void showSuccess(BuildContext context, String message) {
    _showCustomSnackBar(
      context: context,
      message: message,
      backgroundColor: const Color(0xFF15803D),
      foregroundColor: Colors.white,
      icon: Icons.check_circle_rounded,
    );
  }

  /// Error Snackbar
  static void showError(BuildContext context, String message) {
    _showCustomSnackBar(
      context: context,
      message: message,
      backgroundColor: context.colorScheme.error,
      foregroundColor: Colors.white,
      icon: Icons.error_rounded,
    );
  }

  /// Warning Snackbar
  static void showWarning(BuildContext context, String message) {
    _showCustomSnackBar(
      context: context,
      message: message,
      backgroundColor: const Color(0xFFB45309),
      foregroundColor: Colors.white,
      icon: Icons.warning_rounded,
    );
  }

  /// Information Snackbar
  static void showInfo(BuildContext context, String message) {
    _showCustomSnackBar(
      context: context,
      message: message,
      backgroundColor: context.colorScheme.primary,
      foregroundColor: Colors.white,
      icon: Icons.info_rounded,
    );
  }
}
