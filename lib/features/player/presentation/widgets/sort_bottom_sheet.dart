import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:soulsync/core/constants/app_colors.dart';
import 'package:soulsync/core/constants/app_spacing.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';
import 'package:soulsync/features/player/data/repositories/music_repository_impl.dart';
import 'package:soulsync/features/player/presentation/providers/library_provider.dart';

class SortBottomSheet extends ConsumerWidget {
  const SortBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSort = ref.watch(sortOptionProvider);

    return Padding(
      padding: AppSpacing.paddingLG,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sort Music By',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          AppSpacing.vGapSM,
          _buildOption(
              context, ref, SortOption.name, 'Name (A - Z)', currentSort),
          _buildOption(
              context, ref, SortOption.artist, 'Artist Name', currentSort),
          _buildOption(
              context, ref, SortOption.album, 'Album Name', currentSort),
          _buildOption(context, ref, SortOption.duration,
              'Duration (Longest First)', currentSort),
          _buildOption(context, ref, SortOption.dateAdded,
              'Date Added (Newest First)', currentSort),
          AppSpacing.vGapMD,
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context,
    WidgetRef ref,
    SortOption option,
    String label,
    SortOption currentSort,
  ) {
    final isSelected = option == currentSort;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: context.textTheme.bodyMedium?.copyWith(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppColors.primary : context.colorScheme.onSurface,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_rounded, color: AppColors.primary)
          : null,
      onTap: () {
        ref.read(sortOptionProvider.notifier).state = option;
        ref.invalidate(librarySongsProvider);
        Navigator.of(context).pop();
      },
    );
  }
}
