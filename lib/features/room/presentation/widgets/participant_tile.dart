import 'package:flutter/material.dart';
import 'package:soulsync/core/constants/app_colors.dart';
import 'package:soulsync/core/constants/app_radius.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';
import 'package:soulsync/features/room/domain/entities/room_member_entity.dart';
import 'package:soulsync/features/room/presentation/widgets/partner_avatar.dart';

class ParticipantTile extends StatelessWidget {
  final RoomMemberEntity member;

  const ParticipantTile({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: PartnerAvatar(
        name: member.displayName,
        isOnline: member.isOnline,
        size: 40,
      ),
      title: Row(
        children: [
          Text(
            member.displayName,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (member.isHost) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: AppRadius.borderSM,
              ),
              child: Text(
                'HOST',
                style: context.textTheme.labelSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(
        member.statusMessage,
        style: context.textTheme.bodySmall?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        member.isOnline ? Icons.sensors_rounded : Icons.sensors_off_rounded,
        color: member.isOnline ? Colors.green : Colors.grey,
        size: 20,
      ),
    );
  }
}
