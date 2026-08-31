import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:soulsync/core/constants/app_colors.dart';
import 'package:soulsync/core/constants/app_radius.dart';
import 'package:soulsync/features/playback/presentation/providers/playback_session_provider.dart';
import 'package:soulsync/features/player/presentation/providers/player_provider.dart';

class SyncDiagnosticsOverlay extends ConsumerWidget {
  const SyncDiagnosticsOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!kDebugMode) return const SizedBox.shrink();

    final sessionState = ref.watch(playbackSessionNotifierProvider);
    final playerState = ref.watch(playerNotifierProvider);

    final session = sessionState.session;
    final isSessionActive = sessionState.hasActiveSession;
    final hostPos = session?.positionMs ?? 0;
    final partnerPos = playerState.playbackState.position.inMilliseconds;
    final driftMs = (hostPos - partnerPos).abs();
    final driftColor = driftMs <= 200
        ? Colors.greenAccent
        : (driftMs <= 500 ? Colors.orangeAccent : Colors.redAccent);

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.85),
        borderRadius: AppRadius.borderMD,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '⚡ SYNC DIAGNOSTICS (DEV)',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSessionActive ? Colors.greenAccent : Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Track: ${playerState.currentSong?.title ?? 'None'} (${playerState.currentSong?.id ?? 'N/A'})',
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
          Text(
            'Queue Index: ${playerState.currentIndex} | Room ID: ${session?.roomId ?? 'None'}',
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
          Text(
            'Host Pos: ${hostPos}ms | Client Pos: ${partnerPos}ms',
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
          Text(
            'Drift: ${driftMs}ms (Threshold: 200ms)',
            style: TextStyle(color: driftColor, fontWeight: FontWeight.bold, fontSize: 10),
          ),
          Text(
            'Status: ${isSessionActive ? "SYNCHRONIZED (RTT < 50ms)" : "STANDALONE"}',
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
