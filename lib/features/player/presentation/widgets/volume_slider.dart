import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soulsync/core/constants/app_colors.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';
import 'package:soulsync/features/player/presentation/providers/playback_settings_provider.dart';

class VolumeSlider extends ConsumerWidget {
  const VolumeSlider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(playbackSettingsNotifierProvider);
    final notifier = ref.read(playbackSettingsNotifierProvider.notifier);

    IconData iconData = Icons.volume_up_rounded;
    if (settings.volume == 0) {
      iconData = Icons.volume_off_rounded;
    } else if (settings.volume < 0.5) {
      iconData = Icons.volume_down_rounded;
    }

    return Row(
      children: [
        IconButton(
          icon: Icon(iconData, color: context.colorScheme.onSurfaceVariant),
          onPressed: () {
            notifier.setVolume(settings.volume > 0 ? 0.0 : 1.0);
          },
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: context.colorScheme.surfaceContainerHighest,
              thumbColor: AppColors.primary,
              trackHeight: 3.0,
            ),
            child: Slider(
              value: settings.volume,
              onChanged: (val) => notifier.setVolume(val),
            ),
          ),
        ),
      ],
    );
  }
}
