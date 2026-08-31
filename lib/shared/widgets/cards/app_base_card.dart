import 'package:flutter/material.dart';
import 'package:soulsync/core/constants/app_radius.dart';
import 'package:soulsync/core/constants/app_shadows.dart';
import 'package:soulsync/core/constants/app_spacing.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';

/// Reusable Base Card Container component with M3 elevation and glassmorphism options.
class AppBaseCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? shadows;
  final bool hasGlow;

  const AppBaseCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.shadows,
    this.hasGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? AppRadius.borderLG;
    final effectiveBg = backgroundColor ?? context.customColors.cardBackground;
    final effectiveBorderColor =
        borderColor ?? context.customColors.glassBorder;

    return Container(
      margin: margin ??
          const EdgeInsets.symmetric(
              vertical: AppSpacing.xs, horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: effectiveRadius,
        border: Border.all(color: effectiveBorderColor, width: 1.0),
        boxShadow:
            shadows ?? (hasGlow ? AppShadows.cardGlow : AppShadows.small),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: effectiveRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: effectiveRadius,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppSpacing.md),
            child: child,
          ),
        ),
      ),
    );
  }
}
