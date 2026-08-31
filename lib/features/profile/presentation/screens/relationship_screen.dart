import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:soulsync/core/constants/app_colors.dart';
import 'package:soulsync/core/constants/app_radius.dart';
import 'package:soulsync/core/constants/app_spacing.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';
import 'package:soulsync/features/profile/presentation/providers/profile_providers.dart';
import 'package:soulsync/shared/widgets/buttons/app_outlined_button.dart';
import 'package:soulsync/shared/widgets/buttons/app_primary_button.dart';
import 'package:soulsync/shared/widgets/cards/app_base_card.dart';
import 'package:soulsync/shared/widgets/inputs/app_text_field.dart';
import 'package:soulsync/shared/widgets/scaffold/app_scaffold.dart';
import 'package:soulsync/shared/widgets/snackbars/app_snackbars.dart';

class RelationshipScreen extends ConsumerStatefulWidget {
  const RelationshipScreen({super.key});

  @override
  ConsumerState<RelationshipScreen> createState() => _RelationshipScreenState();
}

class _RelationshipScreenState extends ConsumerState<RelationshipScreen> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateInvite() async {
    final success =
        await ref.read(relationshipNotifierProvider.notifier).createInvite();
    if (success && mounted) {
      AppSnackBars.showSuccess(
          context, 'Invitation code created successfully!');
    } else if (mounted) {
      final state = ref.read(relationshipNotifierProvider);
      if (state.errorMessage != null) {
        AppSnackBars.showError(context, state.errorMessage!);
      }
    }
  }

  Future<void> _handleAcceptInvite() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      AppSnackBars.showError(context, 'Please enter an invitation code.');
      return;
    }

    final success = await ref
        .read(relationshipNotifierProvider.notifier)
        .acceptInvite(code);
    if (success && mounted) {
      _codeController.clear();
      AppSnackBars.showSuccess(context, 'Connected with partner!');
    } else if (mounted) {
      final state = ref.read(relationshipNotifierProvider);
      if (state.errorMessage != null) {
        AppSnackBars.showError(context, state.errorMessage!);
      }
    }
  }

  Future<void> _handleRemoveRelationship() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Partner?'),
        content: const Text(
            'Are you sure you want to end this couple relationship?'),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => ctx.pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ref
          .read(relationshipNotifierProvider.notifier)
          .removeRelationship();
      if (success && mounted) {
        AppSnackBars.showInfo(context, 'Relationship removed.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(relationshipNotifierProvider);
    final hasRelationship = state.relationship != null;
    final partner = state.partner;
    final pendingInvite = state.pendingInvitation;

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Couple Relationship'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingLG,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (hasRelationship && partner != null) ...[
                // Connected Partner View
                AppBaseCard(
                  padding: AppSpacing.paddingLG,
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: context.colorScheme.primaryContainer,
                        child: Text(
                          partner.displayName.isNotEmpty
                              ? partner.displayName[0].toUpperCase()
                              : 'P',
                          style: context.textTheme.headlineMedium?.copyWith(
                            color: context.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      AppSpacing.vGapMD,
                      Text(
                        partner.displayName,
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppSpacing.vGapXXS,
                      Text(
                        partner.email,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      AppSpacing.vGapMD,
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.15),
                          borderRadius: AppRadius.borderFull,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                size: 16, color: AppColors.success),
                            AppSpacing.hGapXS,
                            Text(
                              'Connected & Synchronized',
                              style: context.textTheme.labelMedium?.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.vGapLG,

                AppOutlinedButton(
                  label: 'Remove Partner',
                  icon: Icons.heart_broken_rounded,
                  onPressed: _handleRemoveRelationship,
                ),
              ] else ...[
                // Unconnected Invite & Join Flow
                AppBaseCard(
                  padding: AppSpacing.paddingLG,
                  child: Column(
                    children: [
                      const Icon(
                        Icons.favorite_outline_rounded,
                        size: 64,
                        color: AppColors.primary,
                      ),
                      AppSpacing.vGapMD,
                      Text(
                        'Connect with Your Partner',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppSpacing.vGapXS,
                      Text(
                        'Generate an invitation code or enter your partner\'s code to link your accounts.',
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.vGapLG,

                // Active Pending Invitation Code Display
                if (pendingInvite != null) ...[
                  AppBaseCard(
                    padding: AppSpacing.paddingMD,
                    backgroundColor: context.colorScheme.primaryContainer
                        .withValues(alpha: 0.3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Active Invitation Code:',
                          style: context.textTheme.labelMedium?.copyWith(
                            color: context.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        AppSpacing.vGapSM,
                        Row(
                          children: [
                            Text(
                              pendingInvite.invitationCode,
                              style: context.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.copy_rounded),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(
                                    text: pendingInvite.invitationCode));
                                AppSnackBars.showInfo(
                                    context, 'Code copied to clipboard!');
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.vGapMD,
                ] else ...[
                  AppPrimaryButton(
                    label: 'Generate Invite Code',
                    icon: Icons.qr_code_rounded,
                    isLoading: state.isLoading,
                    onPressed: state.isLoading ? null : _handleCreateInvite,
                  ),
                  AppSpacing.vGapLG,
                ],

                // Enter Code to Join Partner
                Text(
                  'Join Partner Using Code',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppSpacing.vGapSM,
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _codeController,
                        hintText: 'e.g. SOUL-4837',
                        prefixIcon: const Icon(Icons.key_rounded),
                      ),
                    ),
                    AppSpacing.hGapMD,
                    AppPrimaryButton(
                      label: 'Join',
                      isLoading: state.isLoading,
                      onPressed: state.isLoading ? null : _handleAcceptInvite,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
