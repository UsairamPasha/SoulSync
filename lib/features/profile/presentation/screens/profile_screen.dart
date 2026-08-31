import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:soulsync/core/constants/app_colors.dart';
import 'package:soulsync/core/constants/app_spacing.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';
import 'package:soulsync/features/auth/presentation/providers/auth_provider.dart';
import 'package:soulsync/features/profile/presentation/providers/profile_providers.dart';
import 'package:soulsync/features/realtime/presentation/widgets/partner_presence_chip.dart';
import 'package:soulsync/features/realtime/presentation/widgets/realtime_status_card.dart';
import 'package:soulsync/shared/providers/shared_providers.dart';
import 'package:soulsync/shared/widgets/buttons/app_outlined_button.dart';
import 'package:soulsync/shared/widgets/buttons/app_primary_button.dart';
import 'package:soulsync/shared/widgets/cards/app_base_card.dart';
import 'package:soulsync/shared/widgets/scaffold/app_scaffold.dart';
import 'package:soulsync/shared/widgets/snackbars/app_snackbars.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileNotifierProvider);
    final profile = profileState.profile;
    final relState = ref.watch(relationshipNotifierProvider);
    final hasPartner = relState.relationship != null;
    final partner = relState.partner;

    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return AppScaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          const PartnerPresenceChip(),
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => context.push('/profile/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.read(profileNotifierProvider.notifier).fetchProfile();
              ref
                  .read(relationshipNotifierProvider.notifier)
                  .fetchRelationship();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingLG,
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // User Avatar & Info Header
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: context.colorScheme.primaryContainer,
                      child: Text(
                        (profile?.displayName.isNotEmpty ?? false)
                            ? profile!.displayName[0].toUpperCase()
                            : 'U',
                        style: context.textTheme.displaySmall?.copyWith(
                          color: context.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    AppSpacing.vGapMD,
                    Text(
                      profile?.displayName ?? 'SoulSync User',
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppSpacing.vGapXXS,
                    Text(
                      profile?.email ?? '',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    AppSpacing.vGapSM,
                    if (profile?.bio.isNotEmpty ?? false) ...[
                      Text(
                        profile!.bio,
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      AppSpacing.vGapSM,
                    ],
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppPrimaryButton(
                            label: 'Edit Profile',
                            icon: Icons.edit_note_rounded,
                            onPressed: () => context.push('/profile/edit'),
                          ),
                          AppSpacing.hGapMD,
                          AppOutlinedButton(
                            label: 'Relationship',
                            icon: Icons.favorite_rounded,
                            onPressed: () =>
                                context.push('/profile/relationship'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              AppSpacing.vGapXL,

              // Realtime WebSocket Status Card
              const RealtimeStatusCard(),

              AppSpacing.vGapMD,

              // Couple Relationship Card Banner
              AppBaseCard(
                margin: EdgeInsets.zero,
                padding: AppSpacing.paddingMD,
                backgroundColor: hasPartner
                    ? AppColors.success.withValues(alpha: 0.12)
                    : context.colorScheme.primaryContainer
                        .withValues(alpha: 0.25),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    hasPartner
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: hasPartner
                        ? AppColors.accent
                        : context.colorScheme.primary,
                  ),
                  title: Text(
                    hasPartner
                        ? 'Connected with ${partner?.displayName ?? "Partner"}'
                        : 'No Partner Linked',
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    hasPartner
                        ? 'Streaming together in real-time.'
                        : 'Tap to generate or enter an invitation code.',
                  ),
                  trailing:
                      const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () => context.push('/profile/relationship'),
                ),
              ),

              AppSpacing.vGapMD,

              // Extended Profile Information Card
              AppBaseCard(
                margin: EdgeInsets.zero,
                padding: AppSpacing.paddingMD,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Music & Listening Preferences',
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colorScheme.primary,
                      ),
                    ),
                    AppSpacing.vGapSM,
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.music_note_rounded,
                          color: AppColors.primary),
                      title: const Text('Favorite Genre'),
                      subtitle: Text(profile?.favoriteGenre ?? 'Lo-Fi / R&B'),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.mic_none_rounded,
                          color: AppColors.primary),
                      title: const Text('Favorite Artist'),
                      subtitle: Text(
                        (profile?.favoriteArtist.isNotEmpty ?? false)
                            ? profile!.favoriteArtist
                            : 'Not specified yet',
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.track_changes_rounded,
                          color: AppColors.primary),
                      title: const Text('Listening Goal'),
                      subtitle: Text(profile?.listeningGoal ?? '30 hrs / week'),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.public_rounded,
                          color: AppColors.primary),
                      title: const Text('Location & Timezone'),
                      subtitle: Text(
                          '${profile?.country ?? "United States"} (${profile?.timezone ?? "UTC"})'),
                    ),
                  ],
                ),
              ),

              AppSpacing.vGapMD,

              // Appearance Settings Card
              AppBaseCard(
                margin: EdgeInsets.zero,
                padding: AppSpacing.paddingMD,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Appearance & Preferences',
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colorScheme.primary,
                      ),
                    ),
                    AppSpacing.vGapSM,
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: Icon(
                        isDarkMode
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        color: AppColors.primary,
                      ),
                      title: const Text('Dark Mode'),
                      subtitle: const Text('Toggle Material 3 Theme'),
                      value: isDarkMode,
                      activeTrackColor: AppColors.primary,
                      onChanged: (val) {
                        ref.read(themeModeProvider.notifier).state =
                            val ? ThemeMode.dark : ThemeMode.light;
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: const Icon(Icons.notifications_active_rounded,
                          color: AppColors.primary),
                      title: const Text('Push Notifications'),
                      subtitle:
                          const Text('Partner sync invitations & messages'),
                      value: _notificationsEnabled,
                      activeTrackColor: AppColors.primary,
                      onChanged: (val) {
                        setState(() {
                          _notificationsEnabled = val;
                        });
                        AppSnackBars.showInfo(
                          context,
                          val ? 'Notifications enabled' : 'Notifications muted',
                        );
                      },
                    ),
                  ],
                ),
              ),

              AppSpacing.vGapXL,

              // Logout Button
              AppOutlinedButton(
                label: 'Sign Out of SoulSync',
                icon: Icons.logout_rounded,
                isFullWidth: true,
                onPressed: () {
                  ref.read(authNotifierProvider.notifier).logout();
                },
              ),

              AppSpacing.vGapLG,
            ],
          ),
        ),
      ),
    );
  }
}
