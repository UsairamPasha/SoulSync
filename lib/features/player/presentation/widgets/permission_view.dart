import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:soulsync/core/constants/app_colors.dart';
import 'package:soulsync/core/constants/app_spacing.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';
import 'package:soulsync/features/player/presentation/providers/permission_provider.dart';
import 'package:soulsync/shared/widgets/buttons/app_primary_button.dart';

class PermissionView extends ConsumerWidget {
  const PermissionView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(permissionNotifierProvider);
    final notifier = ref.read(permissionNotifierProvider.notifier);

    final isPermanentlyDenied =
        status == StoragePermissionStatus.permanentlyDenied;

    return Padding(
      padding: AppSpacing.paddingXL,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.library_music_rounded,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            AppSpacing.vGapLG,
            Text(
              'Music Library Access Required',
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vGapSM,
            Text(
              'SoulSync needs permission to scan your device\'s local music files so you can listen to your favorite tracks together with your partner.',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vGapXL,
            AppPrimaryButton(
              label: isPermanentlyDenied
                  ? 'Open Device Settings'
                  : 'Grant Music Access',
              icon: isPermanentlyDenied
                  ? Icons.settings_rounded
                  : Icons.folder_special_rounded,
              onPressed: () {
                if (isPermanentlyDenied) {
                  notifier.openSettings();
                } else {
                  notifier.requestPermission();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
