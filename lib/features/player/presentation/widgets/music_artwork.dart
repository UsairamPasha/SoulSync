import 'package:flutter/material.dart';
import 'package:soulsync/core/constants/app_colors.dart';
import 'package:soulsync/core/constants/app_radius.dart';

class MusicArtwork extends StatelessWidget {
  final int? songId;
  final double size;

  const MusicArtwork({
    super.key,
    this.songId,
    this.size = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .primaryContainer
            .withValues(alpha: 0.7),
        borderRadius: AppRadius.borderSM,
      ),
      child: Center(
        child: Icon(
          Icons.music_note_rounded,
          size: size * 0.5,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
