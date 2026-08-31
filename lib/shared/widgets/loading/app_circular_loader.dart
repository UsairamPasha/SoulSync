import 'package:flutter/material.dart';
import 'package:soulsync/core/constants/app_spacing.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';

/// Reusable Circular Loader component for SoulSync.
class AppCircularLoader extends StatelessWidget {
  final String? message;
  final double size;

  const AppCircularLoader({
    super.key,
    this.message,
    this.size = 36.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 3.0,
              color: context.colorScheme.primary,
            ),
          ),
          if (message != null) ...[
            AppSpacing.vGapMD,
            Text(
              message!,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
