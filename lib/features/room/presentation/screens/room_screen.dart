import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:soulsync/core/constants/app_colors.dart';
import 'package:soulsync/core/constants/app_spacing.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';
import 'package:soulsync/core/navigation/safe_navigation.dart';
import 'package:soulsync/features/playback/presentation/providers/playback_session_provider.dart';
import 'package:soulsync/features/room/presentation/providers/room_provider.dart';
import 'package:soulsync/features/room/presentation/widgets/invite_code_card.dart';
import 'package:soulsync/features/room/presentation/widgets/participant_tile.dart';
import 'package:soulsync/features/room/presentation/widgets/partner_avatar.dart';
import 'package:soulsync/features/room/presentation/widgets/session_card.dart';
import 'package:soulsync/shared/widgets/buttons/app_outlined_button.dart';
import 'package:soulsync/shared/widgets/buttons/app_primary_button.dart';
import 'package:soulsync/shared/widgets/loading/app_circular_loader.dart';
import 'package:soulsync/shared/widgets/scaffold/app_scaffold.dart';
import 'package:soulsync/shared/widgets/snackbars/app_snackbars.dart';
import 'package:soulsync/shared/widgets/states/app_empty_state.dart';

class RoomScreen extends ConsumerWidget {
  const RoomScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<PlaybackSessionState>(playbackSessionNotifierProvider, (prev, next) {
      final hasActiveRoom = ref.read(roomNotifierProvider).room != null;
      if (hasActiveRoom && next.hasActiveSession && (prev == null || !prev.hasActiveSession)) {
        SafeNavigation.safeGo(context, '/player');
      }
    });

    ref.listen<RoomState>(roomNotifierProvider, (prev, next) {
      if (prev != null && prev.room != null && next.room == null) {
        AppSnackBars.showInfo(context, 'Listening room closed.');
      }
    });

    final roomState = ref.watch(roomNotifierProvider);
    final roomNotifier = ref.read(roomNotifierProvider.notifier);
    final playbackSessionState = ref.watch(playbackSessionNotifierProvider);

    if (roomState.isLoading) {
      return const AppScaffold(
        body: Center(child: AppCircularLoader()),
      );
    }

    final room = roomState.room;
    final members = roomState.members;
    final session = roomState.session;

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Couple Room Dashboard'),
        actions: [
          if (room != null)
            IconButton(
              icon: const Icon(Icons.exit_to_app_rounded),
              onPressed: () {
                final isHost = members.isNotEmpty && members.first.isHost;
                SafeNavigation.safeShowDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(isHost ? 'End Couple Room?' : 'Leave Couple Room?'),
                    content: Text(
                      isHost
                          ? 'Ending the room will disconnect all members and clear active session state.'
                          : 'Are you sure you want to leave this room?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: Text(
                          isHost ? 'End Room' : 'Leave',
                          style: const TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ).then((confirmed) {
                  if (confirmed == true) {
                    if (isHost) {
                      roomNotifier.endRoom();
                    } else {
                      roomNotifier.leaveRoom();
                    }
                  }
                });
              },
              tooltip: 'Leave / End Room',
            ),
        ],
      ),
      body: SafeArea(
        child: room == null
            ? Padding(
                padding: AppSpacing.paddingLG,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const AppEmptyState(
                      title: 'No Active Room',
                      description:
                          'Create a couple room or enter your partner\'s invite code to listen synchronously.',
                      icon: Icons.roofing_rounded,
                    ),
                    AppSpacing.vGapXL,
                    AppPrimaryButton(
                      label: 'Create Couple Room',
                      icon: Icons.add_rounded,
                      onPressed: () => context.push('/room/create'),
                    ),
                    AppSpacing.vGapMD,
                    AppOutlinedButton(
                      label: 'Join with Invite Code',
                      icon: Icons.key_rounded,
                      onPressed: () => context.push('/room/join'),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: AppSpacing.paddingLG,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Room Hero Header Card
                    Container(
                      width: double.infinity,
                      padding: AppSpacing.paddingLG,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primaryDark,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                room.name,
                                style: context.textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              PartnerAvatar(
                                name: members.length > 1
                                    ? members[1].displayName
                                    : 'Partner',
                                isOnline: room.isPartnerConnected,
                                size: 40,
                              ),
                            ],
                          ),
                          AppSpacing.vGapSM,
                          Row(
                            children: [
                              Icon(
                                room.isPartnerConnected
                                    ? Icons.people_rounded
                                    : Icons.person_outline_rounded,
                                color: Colors.white70,
                                size: 16,
                              ),
                              AppSpacing.hGapXS,
                              Text(
                                room.isPartnerConnected
                                    ? 'Both Partners Connected'
                                    : 'Waiting for Partner...',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    AppSpacing.vGapLG,

                    // Invite Code Card
                    InviteCodeCard(inviteCode: room.inviteCode),

                    AppSpacing.vGapLG,

                    // Live Session Card or Action Button
                    Text(
                      'Listening Session',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppSpacing.vGapSM,
                    if (session != null) ...[
                      SessionCard(
                        session: session,
                        onTap: () => SafeNavigation.safeGo(context, '/player'),
                      ),
                    ] else ...[
                      AppPrimaryButton(
                        label: 'Start Listening Session',
                        icon: Icons.graphic_eq_rounded,
                        onPressed: () async {
                          final roomResult =
                              await roomNotifier.startListeningSession();
                          final playbackSuccess = await ref
                              .read(playbackSessionNotifierProvider.notifier)
                              .startSession(room.id);
                          if (!context.mounted) return;
                          if (playbackSuccess || roomResult.success) {
                            AppSnackBars.showSuccess(
                              context,
                              'Synchronized session started!',
                            );
                            SafeNavigation.safeGo(context, '/player');
                          } else {
                            AppSnackBars.showError(
                              context,
                              playbackSessionState.errorMessage ??
                                  roomResult.message ??
                                  'Unable to start session at this time.',
                            );
                          }
                        },
                      ),
                    ],

                    AppSpacing.vGapLG,

                    // Room Members Section
                    Text(
                      'Connected Room Members (${members.length})',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppSpacing.vGapSM,
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        final member = members[index];
                        return ParticipantTile(member: member);
                      },
                    ),

                    AppSpacing.vGapXL,
                  ],
                ),
              ),
      ),
    );
  }
}
