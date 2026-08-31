import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soulsync/core/constants/app_colors.dart';
import 'package:soulsync/core/constants/app_radius.dart';
import 'package:soulsync/core/constants/app_spacing.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';
import 'package:soulsync/features/chat/presentation/providers/chat_provider.dart';
import 'package:soulsync/shared/widgets/scaffold/app_scaffold.dart';

class ChatInfoScreen extends ConsumerWidget {
  const ChatInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatNotifierProvider);
    final conv = chatState.conversation;

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Conversation Info'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingLG,
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.accent],
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'P',
                      style: TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              AppSpacing.vGapMD,
              Text(
                conv?.title ?? 'My Soulmate',
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Synchronized Couple Chat',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              AppSpacing.vGapXL,
              const Card(
                shape: RoundedRectangleBorder(borderRadius: AppRadius.borderLG),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.favorite_rounded,
                          color: AppColors.primary),
                      title: Text('Couple Space'),
                      subtitle: Text('Encrypted private channel'),
                    ),
                    Divider(height: 1),
                    ListTile(
                      leading:
                          Icon(Icons.image_outlined, color: AppColors.primary),
                      title: Text('Shared Media & Music'),
                      subtitle: Text('3 shared tracks & photos'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
