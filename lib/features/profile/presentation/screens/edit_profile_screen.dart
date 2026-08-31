import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:soulsync/core/constants/app_spacing.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';
import 'package:soulsync/features/profile/presentation/providers/profile_providers.dart';
import 'package:soulsync/shared/widgets/buttons/app_outlined_button.dart';
import 'package:soulsync/shared/widgets/buttons/app_primary_button.dart';
import 'package:soulsync/shared/widgets/inputs/app_text_field.dart';
import 'package:soulsync/shared/widgets/scaffold/app_scaffold.dart';
import 'package:soulsync/shared/widgets/snackbars/app_snackbars.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayNameController;
  late TextEditingController _bioController;
  late TextEditingController _genreController;
  late TextEditingController _artistController;
  late TextEditingController _goalController;
  late TextEditingController _timezoneController;
  late TextEditingController _countryController;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileNotifierProvider).profile;
    _displayNameController =
        TextEditingController(text: profile?.displayName ?? '');
    _bioController = TextEditingController(text: profile?.bio ?? '');
    _genreController =
        TextEditingController(text: profile?.favoriteGenre ?? 'Lo-Fi / R&B');
    _artistController =
        TextEditingController(text: profile?.favoriteArtist ?? '');
    _goalController =
        TextEditingController(text: profile?.listeningGoal ?? '30 hrs / week');
    _timezoneController =
        TextEditingController(text: profile?.timezone ?? 'UTC');
    _countryController =
        TextEditingController(text: profile?.country ?? 'United States');
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    _genreController.dispose();
    _artistController.dispose();
    _goalController.dispose();
    _timezoneController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final current = ref.read(profileNotifierProvider).profile;
    if (current == null) return;

    final updated = current.copyWith(
      displayName: _displayNameController.text.trim(),
      bio: _bioController.text.trim(),
      favoriteGenre: _genreController.text.trim(),
      favoriteArtist: _artistController.text.trim(),
      listeningGoal: _goalController.text.trim(),
      timezone: _timezoneController.text.trim(),
      country: _countryController.text.trim(),
    );

    final success =
        await ref.read(profileNotifierProvider.notifier).updateProfile(updated);
    if (success && mounted) {
      AppSnackBars.showSuccess(context, 'Profile updated successfully!');
      context.pop();
    } else if (mounted) {
      final state = ref.read(profileNotifierProvider);
      if (state.errorMessage != null) {
        AppSnackBars.showError(context, state.errorMessage!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileNotifierProvider);
    final isLoading = profileState.isLoading;

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingLG,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Update Profile Details',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppSpacing.vGapSM,
                AppTextField(
                  controller: _displayNameController,
                  labelText: 'Display Name',
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  validator: (val) => (val == null || val.trim().isEmpty)
                      ? 'Name required'
                      : null,
                ),
                AppSpacing.vGapMD,
                AppTextField(
                  controller: _bioController,
                  labelText: 'Bio',
                  hintText: 'Share a short bio with your partner...',
                  maxLines: 3,
                  prefixIcon: const Icon(Icons.notes_rounded),
                ),
                AppSpacing.vGapMD,
                AppTextField(
                  controller: _genreController,
                  labelText: 'Favorite Music Genre',
                  prefixIcon: const Icon(Icons.music_note_rounded),
                ),
                AppSpacing.vGapMD,
                AppTextField(
                  controller: _artistController,
                  labelText: 'Favorite Artist',
                  prefixIcon: const Icon(Icons.mic_none_rounded),
                ),
                AppSpacing.vGapMD,
                AppTextField(
                  controller: _goalController,
                  labelText: 'Listening Goal',
                  prefixIcon: const Icon(Icons.track_changes_rounded),
                ),
                AppSpacing.vGapMD,
                AppTextField(
                  controller: _countryController,
                  labelText: 'Country',
                  prefixIcon: const Icon(Icons.public_rounded),
                ),
                AppSpacing.vGapMD,
                AppTextField(
                  controller: _timezoneController,
                  labelText: 'Timezone',
                  prefixIcon: const Icon(Icons.access_time_rounded),
                ),
                AppSpacing.vGapXL,
                Row(
                  children: [
                    Expanded(
                      child: AppOutlinedButton(
                        label: 'Cancel',
                        onPressed: () => context.pop(),
                      ),
                    ),
                    AppSpacing.hGapMD,
                    Expanded(
                      child: AppPrimaryButton(
                        label: 'Save Changes',
                        isLoading: isLoading,
                        onPressed: isLoading ? null : _handleSave,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
