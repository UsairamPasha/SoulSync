import 'package:flutter/material.dart';
import 'package:soulsync/core/constants/app_radius.dart';
import 'package:soulsync/core/constants/app_spacing.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';

/// Reusable Primary Button component following SoulSync M3 Design System.
class AppPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final bool isFullWidth;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const AppPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.isFullWidth = false,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height = 48.0,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = (isLoading || isDisabled) ? null : onPressed;

    final childWidget = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: foregroundColor ?? context.colorScheme.onPrimary,
            ),
          ),
          AppSpacing.hGapSM,
        ] else if (icon != null) ...[
          Icon(icon,
              size: 20,
              color: foregroundColor ?? context.colorScheme.onPrimary),
          AppSpacing.hGapSM,
        ],
        Text(
          label,
          style: context.textTheme.labelLarge?.copyWith(
            color: foregroundColor ?? context.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );

    final button = ElevatedButton(
      onPressed: effectiveOnPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? context.colorScheme.primary,
        foregroundColor: foregroundColor ?? context.colorScheme.onPrimary,
        elevation: 2,
        minimumSize:
            Size(width ?? (isFullWidth ? double.infinity : 0), height ?? 48.0),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? AppRadius.borderMD,
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      ),
      child: childWidget,
    );

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}
