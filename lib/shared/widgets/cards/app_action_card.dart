import 'package:flutter/material.dart';
import 'package:soulsync/core/constants/app_radius.dart';
import 'package:soulsync/core/constants/app_spacing.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';

/// Actionable Card component for quick features like Create Room, Join Room, New Playlist.
class AppActionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;
  final Gradient? gradient;

  const AppActionCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final defaultGradient = LinearGradient(
      colors: [
        context.colorScheme.primary,
        context.colorScheme.secondary,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Container(
      margin: const EdgeInsets.symmetric(
          vertical: AppSpacing.xs, horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        gradient: gradient ?? defaultGradient,
        borderRadius: AppRadius.borderXL,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.borderXL,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.borderXL,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: context.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppSpacing.vGapXS,
                      Text(
                        description,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 32),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
