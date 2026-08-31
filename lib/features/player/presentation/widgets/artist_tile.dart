import 'package:flutter/material.dart';
import 'package:soulsync/core/constants/app_spacing.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';
import 'package:soulsync/features/player/domain/entities/artist_entity.dart';
import 'package:soulsync/shared/widgets/cards/app_base_card.dart';

class ArtistTile extends StatelessWidget {
  final ArtistEntity artist;
  final VoidCallback onTap;

  const ArtistTile({
    super.key,
    required this.artist,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBaseCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: AppSpacing.paddingMD,
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: context.colorScheme.primaryContainer,
            child: Text(
              artist.name.isNotEmpty ? artist.name[0].toUpperCase() : 'A',
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          AppSpacing.hGapMD,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  artist.name,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.vGapXXS,
                Text(
                  '${artist.numberOfAlbums} albums • ${artist.numberOfTracks} tracks',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}
