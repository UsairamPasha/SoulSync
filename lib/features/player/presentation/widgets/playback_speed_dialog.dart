import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soulsync/core/constants/app_colors.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';
import 'package:soulsync/features/player/presentation/providers/playback_settings_provider.dart';

class PlaybackSpeedDialog extends ConsumerWidget {
  const PlaybackSpeedDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(playbackSettingsNotifierProvider);
    final notifier = ref.read(playbackSettingsNotifierProvider.notifier);

    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

    return AlertDialog(
      title: const Text('Playback Speed'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: speeds.map((speed) {
          final isSelected = settings.speed == speed;
          return ListTile(
            title: Text(
              '${speed}x',
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? AppColors.primary
                    : context.colorScheme.onSurface,
              ),
            ),
            trailing: isSelected
                ? const Icon(Icons.check_rounded, color: AppColors.primary)
                : null,
            onTap: () {
              notifier.setSpeed(speed);
              Navigator.of(context).pop();
            },
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
