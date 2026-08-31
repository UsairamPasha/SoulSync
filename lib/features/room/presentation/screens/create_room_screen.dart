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

class CreateRoomScreen extends ConsumerStatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  ConsumerState<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends ConsumerState<CreateRoomScreen> {
  final _controller = TextEditingController(text: "Usairam & Partner Space");

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onCreate() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;

    final success =
        await ref.read(roomNotifierProvider.notifier).createRoom(name);
    if (mounted) {
      if (success) {
        AppSnackBars.showSuccess(context, 'Couple Room Created!');
        context.pop();
      } else {
        AppSnackBars.showError(context, 'Failed to create room.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final roomState = ref.watch(roomNotifierProvider);

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Create Couple Room'),
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.paddingLG,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Private Listening Space',
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppSpacing.vGapXS,
              Text(
                'Create a private room for you and your partner to listen to music synchronously.',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              AppSpacing.vGapXL,
              AppTextField(
                controller: _controller,
                labelText: 'Room Name',
                hintText: 'Enter couple room name',
                prefixIcon: const Icon(Icons.roofing_rounded),
              ),
              const Spacer(),
              AppPrimaryButton(
                label: 'Create Room',
                isLoading: roomState.isLoading,
                onPressed: _onCreate,
              ),
              AppSpacing.vGapMD,
            ],
          ),
        ),
      ),
    );
  }
}
