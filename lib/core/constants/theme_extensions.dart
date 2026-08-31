import 'package:flutter/material.dart';
import 'package:soulsync/core/constants/app_colors.dart';

/// Custom Material 3 ThemeExtension for SoulSync specific surface variants & accents.
@immutable
class SoulSyncCustomColors extends ThemeExtension<SoulSyncCustomColors> {
  final Color cardBackground;
  final Color glassBorder;
  final Color musicWaveform;
  final Color syncedIndicator;

  const SoulSyncCustomColors({
    required this.cardBackground,
    required this.glassBorder,
    required this.musicWaveform,
    required this.syncedIndicator,
  });

  static const dark = SoulSyncCustomColors(
    cardBackground: AppColors.surfaceDarkVariant,
    glassBorder: Color(0x1FFFFFFF),
    musicWaveform: AppColors.accent,
    syncedIndicator: AppColors.success,
  );

  static const light = SoulSyncCustomColors(
    cardBackground: AppColors.surfaceLightVariant,
    glassBorder: Color(0x1F000000),
    musicWaveform: AppColors.primary,
    syncedIndicator: AppColors.success,
  );

  @override
  SoulSyncCustomColors copyWith({
    Color? cardBackground,
    Color? glassBorder,
    Color? musicWaveform,
    Color? syncedIndicator,
  }) {
    return SoulSyncCustomColors(
      cardBackground: cardBackground ?? this.cardBackground,
      glassBorder: glassBorder ?? this.glassBorder,
      musicWaveform: musicWaveform ?? this.musicWaveform,
      syncedIndicator: syncedIndicator ?? this.syncedIndicator,
    );
  }

  @override
  SoulSyncCustomColors lerp(
      ThemeExtension<SoulSyncCustomColors>? other, double t) {
    if (other is! SoulSyncCustomColors) {
      return this;
    }
    return SoulSyncCustomColors(
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      musicWaveform: Color.lerp(musicWaveform, other.musicWaveform, t)!,
      syncedIndicator: Color.lerp(syncedIndicator, other.syncedIndicator, t)!,
    );
  }
}
