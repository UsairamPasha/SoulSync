import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soulsync/core/constants/app_colors.dart';
import 'package:soulsync/core/constants/app_radius.dart';
import 'package:soulsync/core/constants/app_spacing.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';
import 'package:soulsync/core/navigation/safe_navigation.dart';
import 'package:soulsync/features/home/data/models/dashboard_data_model.dart';
import 'package:soulsync/features/profile/presentation/providers/profile_providers.dart';
import 'package:soulsync/features/realtime/presentation/providers/realtime_providers.dart';
import 'package:soulsync/shared/widgets/cards/app_base_card.dart';

class CoupleStatusCard extends ConsumerWidget {
  final CoupleStatusModel status;

  const CoupleStatusCard({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final relState = ref.watch(relationshipNotifierProvider);
    final presenceState = ref.watch(partnerPresenceNotifierProvider);
    final hasPartner = relState.relationship != null;
    final partner = relState.partner;

    final partnerName = hasPartner
        ? (partner?.displayName.isNotEmpty == true
            ? partner!.displayName
            : status.partnerName)
        : 'No Partner Linked';
    final isOnline = hasPartner && presenceState.isOnline;

    return AppBaseCard(
      margin: EdgeInsets.zero,
      padding: AppSpacing.paddingMD,
      onTap: () => SafeNavigation.safePush(context, '/profile/relationship'),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: context.colorScheme.primaryContainer,
                child: Text(
                  partnerName.isNotEmpty ? partnerName[0].toUpperCase() : '?',
                  style: context.textTheme.titleMedium?.copyWith(
                    color: context.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isOnline
                        ? AppColors.success
                        : context.colorScheme.outline,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: context.colorScheme.surface, width: 2),
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.hGapMD,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        partnerName,
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AppSpacing.hGapXS,
                    Icon(
                      hasPartner
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: 14,
                      color: hasPartner
                          ? AppColors.accent
                          : context.colorScheme.outline,
                    ),
                  ],
                ),
                AppSpacing.vGapXXS,
                Text(
                  hasPartner
                      ? (isOnline ? 'Online • Synchronized Room' : 'Offline')
                      : 'Tap to connect with your partner',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: isOnline
                        ? AppColors.success
                        : context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: (hasPartner
                      ? AppColors.primary
                      : context.colorScheme.outline)
                  .withValues(alpha: 0.12),
              borderRadius: AppRadius.borderFull,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  hasPartner
                      ? Icons.wifi_tethering_rounded
                      : Icons.person_add_rounded,
                  size: 14,
                  color: hasPartner
                      ? AppColors.primary
                      : context.colorScheme.onSurfaceVariant,
                ),
                AppSpacing.hGapXS,
                Text(
                  hasPartner ? 'Connected' : 'Link Partner',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: hasPartner
                        ? AppColors.primary
                        : context.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
