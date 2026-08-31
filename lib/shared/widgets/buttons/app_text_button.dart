import 'package:flutter/material.dart';
import 'package:soulsync/core/constants/app_spacing.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';

/// Reusable Text Button component for inline actions in SoulSync.
class AppTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  final bool isDisabled;

  const AppTextButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.color,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? context.colorScheme.primary;

    return TextButton(
      onPressed: isDisabled ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: effectiveColor,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: effectiveColor),
            AppSpacing.hGapXS,
          ],
          Text(
            label,
            style: context.textTheme.labelLarge?.copyWith(
              color: effectiveColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
