import 'package:flutter/material.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';

/// Reusable Linear Progress Bar loader component for SoulSync.
class AppLinearLoader extends StatelessWidget {
  final double? value;

  const AppLinearLoader({
    super.key,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: value,
      backgroundColor:
          context.colorScheme.primaryContainer.withValues(alpha: 0.3),
      color: context.colorScheme.primary,
      minHeight: 4.0,
    );
  }
}
