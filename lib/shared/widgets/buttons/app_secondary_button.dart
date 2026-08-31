import 'package:flutter/material.dart';
import 'package:soulsync/core/constants/app_radius.dart';
import 'package:soulsync/core/constants/app_spacing.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';

/// Reusable Secondary Filled Button component for SoulSync.
class AppSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final bool isFullWidth;
  final IconData? icon;
  final double? width;
  final double? height;

  const AppSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.isFullWidth = false,
    this.icon,
    this.width,
    this.height = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = (isLoading || isDisabled) ? null : onPressed;

    final button = FilledButton(
      onPressed: effectiveOnPressed,
      style: FilledButton.styleFrom(
        backgroundColor: context.colorScheme.primaryContainer,
        foregroundColor: context.colorScheme.onPrimaryContainer,
        minimumSize:
            Size(width ?? (isFullWidth ? double.infinity : 0), height ?? 48.0),
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.borderMD,
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading) ...[
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: context.colorScheme.onPrimaryContainer,
              ),
            ),
            AppSpacing.hGapSM,
          ] else if (icon != null) ...[
            Icon(icon, size: 20, color: context.colorScheme.onPrimaryContainer),
            AppSpacing.hGapSM,
          ],
          Text(
            label,
            style: context.textTheme.labelLarge?.copyWith(
              color: context.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
