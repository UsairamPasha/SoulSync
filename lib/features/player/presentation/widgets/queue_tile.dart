import 'package:flutter/material.dart';
import 'package:soulsync/core/constants/app_colors.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';
import 'package:soulsync/features/player/domain/entities/song_entity.dart';
import 'package:soulsync/features/player/presentation/widgets/music_artwork.dart';

class QueueTile extends StatelessWidget {
  final SongEntity song;
  final bool isCurrent;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const QueueTile({
    super.key,
    required this.song,
    this.isCurrent = false,
    required this.onTap,
    required this.onRemove,
  });

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final songIdInt = int.tryParse(song.id);

    return Dismissible(
      key: ValueKey('queue_${song.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.error,
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      child: ListTile(
        onTap: onTap,
        leading: MusicArtwork(songId: songIdInt, size: 40),
        title: Text(
          song.title,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
            color:
                isCurrent ? AppColors.primary : context.colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          song.artist,
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
            const SizedBox(width: 8),
            const Icon(Icons.drag_handle_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
