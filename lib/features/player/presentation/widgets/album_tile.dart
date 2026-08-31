import 'package:flutter/material.dart';
import 'package:soulsync/core/constants/app_spacing.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';
import 'package:soulsync/features/player/domain/entities/album_entity.dart';
import 'package:soulsync/features/player/presentation/widgets/music_artwork.dart';
import 'package:soulsync/shared/widgets/cards/app_base_card.dart';

class AlbumTile extends StatelessWidget {
  final AlbumEntity album;
  final VoidCallback onTap;

  const AlbumTile({
    super.key,
    required this.album,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBaseCard(
      margin: EdgeInsets.zero,
      padding: AppSpacing.paddingSM,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: double.infinity,
                child: MusicArtwork(
                  songId: album.id,
                  size: double.infinity,
                ),
              ),
            ),
          ),
          AppSpacing.vGapSM,
          Text(
            album.title,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          AppSpacing.vGapXXS,
          Text(
            '${album.artist} • ${album.numberOfSongs} tracks',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
