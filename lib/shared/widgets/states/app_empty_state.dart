import 'package:flutter/material.dart';
import 'package:soulsync/core/constants/app_icon_sizes.dart';
import 'package:soulsync/core/constants/app_spacing.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';
import 'package:soulsync/shared/widgets/buttons/app_primary_button.dart';

/// Reusable Empty State component with presets for No Songs, No Playlist, No Chat, and No Favorites.
class AppEmptyState extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String? buttonLabel;
  final VoidCallback? onButtonPressed;

  const AppEmptyState({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.buttonLabel,
    this.onButtonPressed,
  });

  factory AppEmptyState.noSongs({VoidCallback? onAddSongs}) {
    return AppEmptyState(
      title: 'No Songs Available',
      description:
          'Your music library is empty. Start adding your favorite tracks!',
      icon: Icons.music_off_rounded,
      buttonLabel: onAddSongs != null ? 'Add Music' : null,
      onButtonPressed: onAddSongs,
    );
  }

  factory AppEmptyState.noPlaylist({VoidCallback? onCreatePlaylist}) {
    return AppEmptyState(
      title: 'No Playlists Created',
      description:
          'Create customized playlists to share and sync with your partner.',
      icon: Icons.playlist_add_rounded,
      buttonLabel: onCreatePlaylist != null ? 'Create Playlist' : null,
      onButtonPressed: onCreatePlaylist,
    );
  }

  factory AppEmptyState.noRecentActivity({VoidCallback? onStartSession}) {
    return AppEmptyState(
      title: 'No Recent Activity',
      description:
          'No recent activity yet.\nStart listening together to create your first memory.',
      icon: Icons.history_toggle_off_rounded,
      buttonLabel: onStartSession != null ? 'Start Session' : null,
      onButtonPressed: onStartSession,
    );
  }

  factory AppEmptyState.noChat({VoidCallback? onStartChat}) {
    return AppEmptyState(
      title: 'No Messages Yet',
      description: 'No messages yet.\nSay hello to your soulmate ❤️',
      icon: Icons.chat_bubble_outline_rounded,
      buttonLabel: onStartChat != null ? 'Start Chat' : null,
      onButtonPressed: onStartChat,
    );
  }

  factory AppEmptyState.emptyQueue({VoidCallback? onAddSongs}) {
    return AppEmptyState(
      title: 'Queue is Empty',
      description: 'Queue is empty.\nAdd songs to start listening together.',
      icon: Icons.queue_music_rounded,
      buttonLabel: onAddSongs != null ? 'Add Songs' : null,
      onButtonPressed: onAddSongs,
    );
  }

  factory AppEmptyState.noFavorites({VoidCallback? onExplore}) {
    return AppEmptyState(
      title: 'No Favorites Saved',
      description:
          'Mark tracks with a heart to collect your favorite shared songs here.',
      icon: Icons.favorite_border_rounded,
      buttonLabel: onExplore != null ? 'Explore Tracks' : null,
      onButtonPressed: onExplore,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingXL,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color:
                    context.colorScheme.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: AppIconSizes.stateIllustration,
                color: context.colorScheme.primary,
              ),
            ),
            AppSpacing.vGapLG,
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.vGapSM,
            Text(
              description,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            if (buttonLabel != null && onButtonPressed != null) ...[
              AppSpacing.vGapXL,
              AppPrimaryButton(
                label: buttonLabel!,
                onPressed: onButtonPressed,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
