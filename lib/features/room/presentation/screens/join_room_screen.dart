import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soulsync/core/constants/app_spacing.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';
import 'package:soulsync/features/room/presentation/providers/room_provider.dart';
import 'package:soulsync/shared/widgets/buttons/app_primary_button.dart';
import 'package:soulsync/shared/widgets/inputs/app_text_field.dart';
import 'package:soulsync/shared/widgets/scaffold/app_scaffold.dart';
import 'package:soulsync/shared/widgets/snackbars/app_snackbars.dart';

class JoinRoomScreen extends ConsumerStatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  ConsumerState<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends ConsumerState<JoinRoomScreen> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _onJoin() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      AppSnackBars.showError(context, 'Please enter invite code.');
      return;
    }

    final success =
        await ref.read(roomNotifierProvider.notifier).joinRoom(code);
    if (mounted) {
      if (success) {
        AppSnackBars.showSuccess(context, 'Joined Couple Room!');
        context.pop();
      } else {
        AppSnackBars.showError(context, 'Invalid or expired invite code.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final roomState = ref.watch(roomNotifierProvider);

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Join Couple Room'),
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.paddingLG,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter Invite Code',
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppSpacing.vGapXS,
              Text(
                'Enter the 4-digit invite code shared by your partner (e.g. SOUL-7892).',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              AppSpacing.vGapXL,
              AppTextField(
                controller: _codeController,
                labelText: 'Invite Code',
                hintText: 'e.g. SOUL-7892',
                prefixIcon: const Icon(Icons.key_rounded),
              ),
              const Spacer(),
              AppPrimaryButton(
                label: 'Join Room',
                isLoading: roomState.isLoading,
                onPressed: _onJoin,
              ),
              AppSpacing.vGapMD,
            ],
          ),
        ),
      ),
    );
  }
}
