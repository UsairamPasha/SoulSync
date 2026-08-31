import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soulsync/core/constants/app_colors.dart';
import 'package:soulsync/core/constants/app_radius.dart';
import 'package:soulsync/core/constants/app_spacing.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';
import 'package:soulsync/features/realtime/presentation/providers/realtime_providers.dart';

import 'package:soulsync/features/playback/presentation/providers/playback_session_provider.dart';
import 'package:soulsync/features/player/presentation/providers/player_provider.dart';

class PartnerPresenceChip extends ConsumerWidget {
  const PartnerPresenceChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presence = ref.watch(partnerPresenceNotifierProvider);
    final sessionState = ref.watch(playbackSessionNotifierProvider);
    final playerState = ref.watch(playerNotifierProvider);

    final isOnline = presence.isOnline;
    final isListeningTogether = isOnline &&
        (sessionState.hasActiveSession || playerState.playbackState.isPlaying);

    String label = 'Offline';
    Color labelColor = context.colorScheme.onSurfaceVariant;

    if (isListeningTogether) {
      label = '🎵 Listening together';
      labelColor = AppColors.primary;
    } else if (isOnline) {
      label = '❤️ Online';
      labelColor = AppColors.success;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: labelColor.withValues(alpha: 0.15),
        borderRadius: AppRadius.borderFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: labelColor,
            ),
          ),
          AppSpacing.hGapXS,
          Text(
            label,
            style: context.textTheme.labelSmall?.copyWith(
              color: labelColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
