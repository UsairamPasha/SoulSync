import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:soulsync/core/constants/app_colors.dart';
import 'package:soulsync/core/constants/app_spacing.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';
import 'package:soulsync/features/player/domain/entities/song_entity.dart';
import 'package:soulsync/features/player/presentation/providers/library_provider.dart';
import 'package:soulsync/features/player/presentation/providers/player_provider.dart';
import 'package:soulsync/features/player/presentation/widgets/music_artwork.dart';

class SongTile extends ConsumerWidget {
  final SongEntity song;
  final VoidCallback onTap;

  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
  });

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerNotifierProvider);
    final isCurrent = playerState.currentSong?.id == song.id;

    final songIdInt = int.tryParse(song.id);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      onTap: onTap,
      leading: MusicArtwork(
        songId: songIdInt,
        size: 48,
      ),
      title: Text(
        song.title,
        style: context.textTheme.bodyMedium?.copyWith(
          fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
          color: isCurrent ? AppColors.primary : context.colorScheme.onSurface,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${song.artist} • ${song.album}',
        style: context.textTheme.bodySmall?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _formatDuration(song.duration),
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          AppSpacing.hGapXS,
          IconButton(
            icon: Icon(
              song.isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: song.isFavorite
                  ? AppColors.accent
                  : context.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            onPressed: () async {
              final repo = ref.read(musicRepositoryProvider);
              await repo.toggleFavorite(song.id);
              ref.invalidate(librarySongsProvider);
              ref.invalidate(favoriteSongsProvider);
            },
          ),
        ],
      ),
    );
  }
}
