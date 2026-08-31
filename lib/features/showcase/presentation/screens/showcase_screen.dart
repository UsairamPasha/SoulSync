import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:soulsync/core/constants/app_colors.dart';
import 'package:soulsync/core/constants/app_radius.dart';
import 'package:soulsync/core/constants/app_spacing.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';
import 'package:soulsync/shared/models/track_model.dart';
import 'package:soulsync/shared/providers/shared_providers.dart';

// Import Shared Component Library
import 'package:soulsync/shared/widgets/buttons/app_icon_button.dart';
import 'package:soulsync/shared/widgets/buttons/app_outlined_button.dart';
import 'package:soulsync/shared/widgets/buttons/app_primary_button.dart';
import 'package:soulsync/shared/widgets/buttons/app_secondary_button.dart';
import 'package:soulsync/shared/widgets/buttons/app_text_button.dart';

import 'package:soulsync/shared/widgets/inputs/app_email_text_field.dart';
import 'package:soulsync/shared/widgets/inputs/app_password_text_field.dart';
import 'package:soulsync/shared/widgets/inputs/app_search_text_field.dart';
import 'package:soulsync/shared/widgets/inputs/app_text_field.dart';

import 'package:soulsync/shared/widgets/cards/app_action_card.dart';
import 'package:soulsync/shared/widgets/cards/app_base_card.dart';
import 'package:soulsync/shared/widgets/cards/app_info_card.dart';
import 'package:soulsync/shared/widgets/cards/app_music_card.dart';
import 'package:soulsync/shared/widgets/cards/app_settings_card.dart';

import 'package:soulsync/shared/widgets/loading/app_circular_loader.dart';
import 'package:soulsync/shared/widgets/loading/app_linear_loader.dart';
import 'package:soulsync/shared/widgets/loading/app_skeleton_loader.dart';

import 'package:soulsync/shared/widgets/states/app_empty_state.dart';
import 'package:soulsync/shared/widgets/states/app_error_state.dart';

import 'package:soulsync/shared/widgets/dialogs/app_dialogs.dart';
import 'package:soulsync/shared/widgets/snackbars/app_snackbars.dart';
import 'package:soulsync/shared/widgets/scaffold/app_scaffold.dart';

/// Storybook / Widgetbook style Showcase Screen displaying every reusable UI component in SoulSync.
class ShowcaseScreen extends ConsumerStatefulWidget {
  const ShowcaseScreen({super.key});

  @override
  ConsumerState<ShowcaseScreen> createState() => _ShowcaseScreenState();
}

class _ShowcaseScreenState extends ConsumerState<ShowcaseScreen> {
  bool _isLoadingOverlay = false;

  final sampleTrack = const TrackModel(
    id: 'track-1',
    title: 'Midnight Sync (Acoustic)',
    artist: 'SoulSync Duo',
    album: 'Together in Harmony',
    duration: Duration(minutes: 3, seconds: 45),
    streamUrl: 'https://sample.audio/track-1.mp3',
  );

  @override
  Widget build(BuildContext context) {
    final currentThemeMode = ref.watch(themeModeProvider);
    final isDark = currentThemeMode == ThemeMode.dark;

    return AppScaffold(
      isLoading: _isLoadingOverlay,
      loadingMessage: 'Testing full screen overlay loader...',
      appBar: AppBar(
        title: const Text('UI Design System Showcase'),
        actions: [
          IconButton(
            icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
            tooltip: 'Toggle Theme',
            onPressed: () {
              ref.read(themeModeProvider.notifier).state =
                  isDark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
        ],
      ),
      body: ListView(
        padding: AppSpacing.paddingMD,
        children: [
          // Theme Control Banner
          AppBaseCard(
            hasGlow: true,
            child: Row(
              children: [
                Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: context.colorScheme.primary,
                  size: 28,
                ),
                AppSpacing.hGapMD,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Active Theme: ${isDark ? "Dark Theme" : "Light Theme"}',
                        style: context.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Tap the top-right button to test M3 Light/Dark switching.',
                        style: context.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.vGapLG,

          // 1. Color Palette Tokens Section
          _buildSectionHeader('1. Color Palette Tokens'),
          AppSpacing.vGapSM,
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _buildColorChip('Primary', AppColors.primary),
              _buildColorChip('Secondary', AppColors.secondary),
              _buildColorChip('Accent', AppColors.accent),
              _buildColorChip('Success', AppColors.success),
              _buildColorChip('Warning', AppColors.warning),
              _buildColorChip('Error', AppColors.error),
              _buildColorChip('Surface', context.colorScheme.surface),
              _buildColorChip(
                  'Background', context.theme.scaffoldBackgroundColor),
            ],
          ),
          AppSpacing.vGapLG,

          // 2. Typography Styles
          _buildSectionHeader('2. Plus Jakarta Sans Typography'),
          AppSpacing.vGapSM,
          Text('Display Large (32pt)', style: context.textTheme.displayLarge),
          Text('Display Medium (28pt)', style: context.textTheme.displayMedium),
          Text('Headline Large (24pt)', style: context.textTheme.headlineLarge),
          Text('Headline Medium (20pt)',
              style: context.textTheme.headlineMedium),
          Text('Title Large (18pt)', style: context.textTheme.titleLarge),
          Text('Title Medium (16pt)', style: context.textTheme.titleMedium),
          Text('Body Large (16pt)', style: context.textTheme.bodyLarge),
          Text('Body Medium (14pt)', style: context.textTheme.bodyMedium),
          Text('Body Small (12pt)', style: context.textTheme.bodySmall),
          Text('Label Large (14pt Bold)', style: context.textTheme.labelLarge),
          AppSpacing.vGapLG,

          // 3. Buttons Library
          _buildSectionHeader('3. Reusable Buttons Library'),
          AppSpacing.vGapSM,
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              AppPrimaryButton(
                label: 'Primary Button',
                onPressed: () {},
              ),
              AppPrimaryButton(
                label: 'With Icon',
                icon: Icons.play_arrow_rounded,
                onPressed: () {},
              ),
              const AppPrimaryButton(
                label: 'Loading State',
                isLoading: true,
              ),
              const AppPrimaryButton(
                label: 'Disabled',
                isDisabled: true,
              ),
              AppSecondaryButton(
                label: 'Secondary Button',
                icon: Icons.tune_rounded,
                onPressed: () {},
              ),
              AppOutlinedButton(
                label: 'Outlined Button',
                icon: Icons.favorite_border_rounded,
                onPressed: () {},
              ),
              AppTextButton(
                label: 'Text Action Button',
                icon: Icons.arrow_forward_rounded,
                onPressed: () {},
              ),
              AppIconButton(
                icon: Icons.share_rounded,
                hasContainer: true,
                onPressed: () {},
              ),
            ],
          ),
          AppSpacing.vGapMD,
          AppPrimaryButton(
            label: 'Full Width Primary Button',
            isFullWidth: true,
            onPressed: () {},
          ),
          AppSpacing.vGapLG,

          // 4. Input Fields Library
          _buildSectionHeader('4. Reusable Input Fields'),
          AppSpacing.vGapSM,
          const AppTextField(
            labelText: 'Standard Text Field',
            hintText: 'Enter room name or music query...',
            prefixIcon: Icon(Icons.edit_note_rounded),
          ),
          AppSpacing.vGapMD,
          const AppEmailTextField(),
          AppSpacing.vGapMD,
          const AppPasswordTextField(),
          AppSpacing.vGapMD,
          const AppSearchTextField(),
          AppSpacing.vGapLG,

          // 5. Reusable Cards Library
          _buildSectionHeader('5. Reusable Cards Library'),
          AppSpacing.vGapSM,
          AppMusicCard(
            track: sampleTrack,
            isPlaying: true,
            isFavorite: true,
            onTap: () {},
            onMoreTap: () {},
          ),
          AppInfoCard(
            title: 'Synchronized Playback Active',
            description:
                'Playback position is locked within ±15ms between your devices.',
            icon: Icons.sync_lock_rounded,
            onTap: () {},
          ),
          AppSettingsCard(
            title: 'High Quality Audio Streaming',
            subtitle: 'FLAC Lossless 24-bit / 96kHz enabled',
            icon: Icons.high_quality_rounded,
            trailing: Switch(
              value: true,
              onChanged: (val) {},
            ),
          ),
          AppActionCard(
            title: 'Create Sync Room',
            description:
                'Start a synchronized private music listening room with your partner.',
            icon: Icons.add_circle_outline_rounded,
            onTap: () {},
          ),
          AppSpacing.vGapLG,

          // 6. Loading Indicators
          _buildSectionHeader('6. Loaders & Skeleton Shimmers'),
          AppSpacing.vGapSM,
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              AppCircularLoader(message: 'Loading track...'),
              SizedBox(
                width: 150,
                child: AppLinearLoader(),
              ),
            ],
          ),
          AppSpacing.vGapMD,
          const AppSkeletonTile(),
          AppSpacing.vGapMD,
          AppPrimaryButton(
            label: 'Test Full Screen Overlay Loader (3s)',
            onPressed: () async {
              setState(() => _isLoadingOverlay = true);
              await Future<void>.delayed(const Duration(seconds: 3));
              if (mounted) setState(() => _isLoadingOverlay = false);
            },
          ),
          AppSpacing.vGapLG,

          // 7. Dialog System
          _buildSectionHeader('7. Reusable Dialog System'),
          AppSpacing.vGapSM,
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              AppOutlinedButton(
                label: 'Confirmation',
                onPressed: () => AppDialogs.showConfirmation(
                  context: context,
                  title: 'Leave Room?',
                  message: 'Disconnecting will pause synchronized playback.',
                ),
              ),
              AppOutlinedButton(
                label: 'Delete Dialog',
                borderColor: context.colorScheme.error,
                onPressed: () => AppDialogs.showDelete(
                  context: context,
                  title: 'Delete Playlist',
                  message:
                      'Are you sure you want to delete this shared playlist?',
                ),
              ),
              AppOutlinedButton(
                label: 'Success Dialog',
                onPressed: () => AppDialogs.showSuccess(
                  context: context,
                  title: 'Room Created',
                  message: 'Your private sync room is ready for connection.',
                ),
              ),
              AppOutlinedButton(
                label: 'Error Dialog',
                onPressed: () => AppDialogs.showError(
                  context: context,
                  title: 'Connection Failed',
                  message: 'Could not connect to host socket server.',
                ),
              ),
            ],
          ),
          AppSpacing.vGapLG,

          // 8. Snackbar System
          _buildSectionHeader('8. Reusable Snackbar System'),
          AppSpacing.vGapSM,
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              AppSecondaryButton(
                label: 'Success Toast',
                onPressed: () => AppSnackBars.showSuccess(
                    context, 'Track added to shared queue!'),
              ),
              AppSecondaryButton(
                label: 'Error Toast',
                onPressed: () =>
                    AppSnackBars.showError(context, 'Failed to fetch lyrics.'),
              ),
              AppSecondaryButton(
                label: 'Warning Toast',
                onPressed: () => AppSnackBars.showWarning(
                    context, 'Partner network latency is high (120ms).'),
              ),
              AppSecondaryButton(
                label: 'Info Toast',
                onPressed: () =>
                    AppSnackBars.showInfo(context, 'Sync room buffer updated.'),
              ),
            ],
          ),
          AppSpacing.vGapLG,

          // 9. Empty States Presets
          _buildSectionHeader('9. Empty State Presets'),
          AppSpacing.vGapSM,
          SizedBox(
            height: 320,
            child: AppBaseCard(
              child: AppEmptyState.noSongs(
                onAddSongs: () {},
              ),
            ),
          ),
          AppSpacing.vGapLG,

          // 10. Error State Presets
          _buildSectionHeader('10. Error State Presets'),
          AppSpacing.vGapSM,
          SizedBox(
            height: 340,
            child: AppBaseCard(
              child: AppErrorState.network(
                onRetry: () {},
              ),
            ),
          ),
          AppSpacing.vGapXXL,
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colorScheme.primary,
          ),
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildColorChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadius.borderMD,
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        label,
        style: context.textTheme.labelMedium?.copyWith(
          color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
