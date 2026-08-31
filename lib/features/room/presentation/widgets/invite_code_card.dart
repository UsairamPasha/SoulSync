import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soulsync/core/constants/app_colors.dart';
import 'package:soulsync/core/constants/app_radius.dart';
import 'package:soulsync/core/constants/app_spacing.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';
import 'package:soulsync/shared/widgets/snackbars/app_snackbars.dart';

class InviteCodeCard extends StatelessWidget {
  final String inviteCode;

  const InviteCodeCard({super.key, required this.inviteCode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: AppRadius.borderLG,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.qr_code_rounded,
            size: 36,
            color: AppColors.primary,
          ),
          AppSpacing.hGapMD,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Couple Invite Code',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  inviteCode,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy_rounded),
            color: AppColors.primary,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: inviteCode));
              AppSnackBars.showSuccess(
                  context, 'Invite code copied to clipboard!');
            },
            tooltip: 'Copy Invite Code',
          ),
        ],
      ),
    );
  }
}
