import 'package:flutter/material.dart';
import 'package:soulsync/core/constants/app_radius.dart';
import 'package:soulsync/core/constants/app_spacing.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';
import 'package:soulsync/shared/widgets/buttons/app_outlined_button.dart';
import 'package:soulsync/shared/widgets/buttons/app_primary_button.dart';

/// Centralized Reusable Dialog System for SoulSync.
abstract class AppDialogs {
  /// Confirmation Dialog
  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    IconData icon = Icons.help_outline_rounded,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderXL),
        title: Row(
          children: [
            Icon(icon, color: context.colorScheme.primary, size: 28),
            AppSpacing.hGapMD,
            Expanded(
              child: Text(
                title,
                style: context.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(message, style: context.textTheme.bodyMedium),
        actions: [
          AppOutlinedButton(
            label: cancelLabel,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          AppPrimaryButton(
            label: confirmLabel,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }

  /// Destructive Delete Confirmation Dialog
  static Future<bool?> showDelete({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Delete',
    String cancelLabel = 'Cancel',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderXL),
        title: Row(
          children: [
            Icon(Icons.delete_forever_rounded,
                color: context.colorScheme.error, size: 28),
            AppSpacing.hGapMD,
            Expanded(
              child: Text(
                title,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colorScheme.error,
                ),
              ),
            ),
          ],
        ),
        content: Text(message, style: context.textTheme.bodyMedium),
        actions: [
          AppOutlinedButton(
            label: cancelLabel,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          AppPrimaryButton(
            label: confirmLabel,
            backgroundColor: context.colorScheme.error,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }

  /// Success Dialog
  static Future<void> showSuccess({
    required BuildContext context,
    required String title,
    required String message,
    String buttonLabel = 'Awesome',
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderXL),
        title: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Color(0xFF22C55E), size: 28),
            AppSpacing.hGapMD,
            Expanded(
              child: Text(
                title,
                style: context.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(message, style: context.textTheme.bodyMedium),
        actions: [
          AppPrimaryButton(
            label: buttonLabel,
            backgroundColor: const Color(0xFF22C55E),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  /// Error Dialog
  static Future<void> showError({
    required BuildContext context,
    required String title,
    required String message,
    String buttonLabel = 'Dismiss',
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderXL),
        title: Row(
          children: [
            Icon(Icons.error_rounded,
                color: context.colorScheme.error, size: 28),
            AppSpacing.hGapMD,
            Expanded(
              child: Text(
                title,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colorScheme.error,
                ),
              ),
            ),
          ],
        ),
        content: Text(message, style: context.textTheme.bodyMedium),
        actions: [
          AppPrimaryButton(
            label: buttonLabel,
            backgroundColor: context.colorScheme.error,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  /// Information Dialog
  static Future<void> showInfo({
    required BuildContext context,
    required String title,
    required String message,
    String buttonLabel = 'Got It',
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderXL),
        title: Row(
          children: [
            Icon(Icons.info_rounded,
                color: context.colorScheme.primary, size: 28),
            AppSpacing.hGapMD,
            Expanded(
              child: Text(
                title,
                style: context.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(message, style: context.textTheme.bodyMedium),
        actions: [
          AppPrimaryButton(
            label: buttonLabel,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
