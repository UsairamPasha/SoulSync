import 'package:flutter/material.dart';
import 'package:soulsync/core/constants/app_radius.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';

/// Reusable Icon Button component with optional container background for SoulSync.
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;
  final Color? color;
  final Color? backgroundColor;
  final String? tooltip;
  final bool hasContainer;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 44.0,
    this.iconSize = 22.0,
    this.color,
    this.backgroundColor,
    this.tooltip,
    this.hasContainer = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? context.colorScheme.onSurface;
    final effectiveBg =
        backgroundColor ?? context.colorScheme.surfaceContainerHighest;

    Widget iconWidget = Icon(icon, size: iconSize, color: effectiveColor);

    if (tooltip != null) {
      iconWidget = Tooltip(message: tooltip!, child: iconWidget);
    }

    if (hasContainer) {
      return Material(
        color: effectiveBg,
        borderRadius: AppRadius.borderFull,
        child: InkWell(
          onTap: onPressed,
          borderRadius: AppRadius.borderFull,
          child: Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            child: iconWidget,
          ),
        ),
      );
    }

    return IconButton(
      onPressed: onPressed,
      icon: iconWidget,
      iconSize: iconSize,
      splashRadius: size / 2,
    );
  }
}
