import 'package:flutter/material.dart';
import 'package:soulsync/core/constants/app_radius.dart';
import 'package:soulsync/core/constants/app_spacing.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';

/// Reusable Outlined Button component for SoulSync.
class AppOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final bool isFullWidth;
  final IconData? icon;
  final Color? borderColor;
  final double? width;
  final double? height;

  const AppOutlinedButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.isFullWidth = false,
    this.icon,
    this.borderColor,
    this.width,
    this.height = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = (isLoading || isDisabled) ? null : onPressed;

    final button = OutlinedButton(
      onPressed: effectiveOnPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: borderColor ?? context.colorScheme.primary,
        side: BorderSide(
            color: borderColor ?? context.colorScheme.primary, width: 1.5),
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
                color: borderColor ?? context.colorScheme.primary,
              ),
            ),
            AppSpacing.hGapSM,
          ] else if (icon != null) ...[
            Icon(icon,
                size: 20, color: borderColor ?? context.colorScheme.primary),
            AppSpacing.hGapSM,
          ],
          Text(
            label,
            style: context.textTheme.labelLarge?.copyWith(
              color: borderColor ?? context.colorScheme.primary,
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
