import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:soulsync/core/constants/app_spacing.dart';
import 'package:soulsync/features/auth/presentation/providers/auth_provider.dart';
import 'package:soulsync/features/home/presentation/providers/dashboard_provider.dart';
import 'package:soulsync/features/home/presentation/widgets/couple_status_card.dart';
import 'package:soulsync/features/home/presentation/widgets/current_song_card.dart';
import 'package:soulsync/features/home/presentation/widgets/dashboard_header.dart';
import 'package:soulsync/features/home/presentation/widgets/hero_card.dart';
import 'package:soulsync/features/home/presentation/widgets/quick_action_grid.dart';
import 'package:soulsync/features/home/presentation/widgets/recent_activity_section.dart';
import 'package:soulsync/features/home/presentation/widgets/stats_section.dart';

import 'package:soulsync/shared/widgets/loading/app_shimmer.dart';
import 'package:soulsync/shared/widgets/scaffold/app_scaffold.dart';
import 'package:soulsync/shared/widgets/states/app_error_state.dart';

/// Premium Home Dashboard Screen for SoulSync Application Shell.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final dashboardAsync = ref.watch(dashboardDataProvider);

    return AppScaffold(
      body: dashboardAsync.when(
        data: (dashboard) => SafeArea(
          child: SingleChildScrollView(
            padding: AppSpacing.paddingLG,
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DashboardHeader(
                  userName: user?.displayName ?? 'Usairam',
                  avatarUrl: user?.avatarUrl,
                ),
                AppSpacing.vGapLG,
                const HeroCard(),
                AppSpacing.vGapLG,
                CoupleStatusCard(status: dashboard.coupleStatus),
                AppSpacing.vGapLG,
                const CurrentSongCard(),
                AppSpacing.vGapLG,
                const QuickActionGrid(),
                AppSpacing.vGapLG,
                RecentActivitySection(activities: dashboard.recentActivities),
                AppSpacing.vGapLG,
                StatsSection(stats: dashboard.stats),
                AppSpacing.vGapXL,
              ],
            ),
          ),
        ),
        loading: () => SafeArea(
          child: Padding(
            padding: AppSpacing.paddingLG,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppShimmer.circle(size: 48),
                    AppSpacing.hGapMD,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppShimmer(width: 120, height: 16),
                        AppSpacing.vGapXS,
                        AppShimmer(width: 80, height: 12),
                      ],
                    ),
                  ],
                ),
                AppSpacing.vGapLG,
                AppShimmer.card(height: 140),
                AppSpacing.vGapLG,
                AppShimmer.card(height: 90),
                AppSpacing.vGapLG,
                AppShimmer.card(height: 120),
              ],
            ),
          ),
        ),
        error: (err, stack) => Center(
          child: AppErrorState.generic(
            message: 'Failed to load dashboard data',
            onRetry: () => ref.invalidate(dashboardDataProvider),
          ),
        ),
      ),
    );
  }
}
