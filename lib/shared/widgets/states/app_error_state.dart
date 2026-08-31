import 'package:flutter/material.dart';
import 'package:soulsync/core/constants/app_icon_sizes.dart';
import 'package:soulsync/core/constants/app_spacing.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';
import 'package:soulsync/shared/widgets/buttons/app_primary_button.dart';

/// Reusable Error State component with presets for Network Error, Server Error, and Generic Errors.
class AppErrorState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onRetry;
  final String retryLabel;

  const AppErrorState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.error_outline_rounded,
    this.onRetry,
    this.retryLabel = 'Try Again',
  });

  factory AppErrorState.network({VoidCallback? onRetry}) {
    return AppErrorState(
      title: 'Connection Lost',
      message:
          'Unable to reach SoulSync servers. Please check your internet connection and try again.',
      icon: Icons.wifi_off_rounded,
      onRetry: onRetry,
    );
  }

  factory AppErrorState.server({VoidCallback? onRetry}) {
    return AppErrorState(
      title: 'Server Unreachable',
      message:
          'Something went wrong on our end. We are working to resolve it quickly.',
      icon: Icons.cloud_off_rounded,
      onRetry: onRetry,
    );
  }

  factory AppErrorState.generic(
      {required String message, VoidCallback? onRetry}) {
    return AppErrorState(
      title: 'An Error Occurred',
      message: message,
      icon: Icons.warning_amber_rounded,
      onRetry: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingXL,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: context.colorScheme.error.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: AppIconSizes.stateIllustration,
                color: context.colorScheme.error,
              ),
            ),
            AppSpacing.vGapLG,
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.vGapSM,
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            if (onRetry != null) ...[
              AppSpacing.vGapXL,
              AppPrimaryButton(
                label: retryLabel,
                icon: Icons.refresh_rounded,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
