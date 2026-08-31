import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:soulsync/core/constants/app_radius.dart';
import 'package:soulsync/core/constants/app_spacing.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';
import 'package:soulsync/shared/widgets/buttons/app_outlined_button.dart';
import 'package:soulsync/shared/widgets/buttons/app_primary_button.dart';
import 'package:soulsync/shared/widgets/scaffold/app_scaffold.dart';

/// Onboarding Welcome Screen for SoulSync.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Padding(
        padding: AppSpacing.paddingLG,
        child: Column(
          children: [
            const Spacer(),

            // Hero Illustration & App Icon Banner
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.colorScheme.primary,
                    context.colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: AppRadius.borderFull,
                boxShadow: [
                  BoxShadow(
                    color: context.colorScheme.primary.withValues(alpha: 0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.favorite_rounded,
                size: 64,
                color: Colors.white,
              ),
            ),
            AppSpacing.vGapXL,

            // App Title & Tagline
            Text(
              'SoulSync',
              style: context.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colorScheme.primary,
              ),
            ),
            AppSpacing.vGapXS,
            Text(
              'Synchronized Music for Two',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colorScheme.onSurface,
              ),
            ),
            AppSpacing.vGapMD,
            Text(
              'Stream audio seamlessly in real-time, share private playlists, and stay connected with your partner wherever you are.',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),

            const Spacer(),

            // Action Buttons using Sprint 1.2 Design System
            AppPrimaryButton(
              label: 'Create Account',
              icon: Icons.person_add_outlined,
              isFullWidth: true,
              onPressed: () => context.push('/register'),
            ),
            AppSpacing.vGapMD,
            AppOutlinedButton(
              label: 'Sign In',
              isFullWidth: true,
              onPressed: () => context.push('/login'),
            ),
            AppSpacing.vGapLG,
          ],
        ),
      ),
    );
  }
}
