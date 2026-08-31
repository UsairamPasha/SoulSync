import 'package:flutter/material.dart';
import 'package:soulsync/core/constants/app_colors.dart';

class QueueTile extends StatelessWidget {
  final String title;
  final String artist;
  final String duration;
  final bool isCurrentlyPlaying;
  final bool isHost;
  final VoidCallback? onTap;
  final VoidCallback? onPlayNext;
  final VoidCallback? onRemove;
  final Widget? dragHandle;

  const QueueTile({
    super.key,
    required this.title,
    required this.artist,
    required this.duration,
    this.isCurrentlyPlaying = false,
    this.isHost = false,
    this.onTap,
    this.onPlayNext,
    this.onRemove,
    this.dragHandle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      decoration: BoxDecoration(
        color: isCurrentlyPlaying
            ? AppColors.primary.withValues(alpha: 0.12)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: isCurrentlyPlaying
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1.5)
            : Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: isCurrentlyPlaying
            ? Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.equalizer_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              )
            : CircleAvatar(
                backgroundColor: AppColors.surfaceLightVariant,
                child: Text(
                  title.isNotEmpty ? title[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: isCurrentlyPlaying ? FontWeight.bold : FontWeight.w600,
                  color: isCurrentlyPlaying ? AppColors.primary : theme.colorScheme.onSurface,
                  fontSize: 15,
                ),
              ),
            ),
            if (isCurrentlyPlaying)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'NOW PLAYING',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(
          '$artist • $duration',
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
            fontSize: 12,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onPlayNext != null)
              IconButton(
                icon: const Icon(Icons.playlist_add_rounded, size: 20),
                tooltip: 'Play Next',
                onPressed: onPlayNext,
              ),
            if (onRemove != null)
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.error),
                tooltip: 'Remove',
                onPressed: onRemove,
              ),
            if (dragHandle != null) dragHandle!,
          ],
        ),
      ),
    );
  }
}
