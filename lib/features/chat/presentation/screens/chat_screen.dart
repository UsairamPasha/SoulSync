import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:soulsync/core/constants/app_colors.dart';
import 'package:soulsync/core/constants/app_spacing.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';
import 'package:soulsync/features/chat/presentation/providers/chat_provider.dart';
import 'package:soulsync/features/chat/presentation/providers/draft_provider.dart';
import 'package:soulsync/features/chat/presentation/widgets/chat_bubble.dart';
import 'package:soulsync/features/chat/presentation/widgets/message_input.dart';
import 'package:soulsync/features/chat/presentation/widgets/reaction_bar.dart';
import 'package:soulsync/features/chat/presentation/widgets/typing_indicator.dart';
import 'package:soulsync/shared/widgets/loading/app_circular_loader.dart';
import 'package:soulsync/shared/widgets/scaffold/app_scaffold.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  void _showReactionPicker(
      BuildContext context, WidgetRef ref, String messageId) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Center(
          child: ReactionBar(
            onSelectEmoji: (emoji) {
              ref
                  .read(chatNotifierProvider.notifier)
                  .toggleReaction(messageId, emoji);
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatNotifierProvider);
    final chatNotifier = ref.read(chatNotifierProvider.notifier);

    if (chatState.isLoading) {
      return const AppScaffold(
        body: Center(child: AppCircularLoader()),
      );
    }

    final conversation = chatState.conversation;
    final messages = chatState.messages;
    final typingStatus = chatState.typingStatus;
    final draftText =
        ref.watch(draftNotifierProvider(conversation?.id ?? 'c1'));
    final draftNotifier =
        ref.read(draftNotifierProvider(conversation?.id ?? 'c1').notifier);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatNotifierProvider.notifier).markAsRead();
    });

    return AppScaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: () => context.push('/chat/info'),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary,
                child: Text(
                  conversation?.title.isNotEmpty == true
                      ? conversation!.title[0].toUpperCase()
                      : 'P',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              AppSpacing.hGapSM,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversation?.title ?? 'My Soulmate',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Online • Couple Channel',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => context.push('/chat/search'),
            tooltip: 'Search Messages',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => context.push('/chat/info'),
            tooltip: 'Chat Info',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 40,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No messages yet.',
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Say hello to your soulmate ❤️',
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isMe = msg.senderId == 'user_me';

                        return ChatBubble(
                          message: msg,
                          isMe: isMe,
                          onLongPress: () =>
                              _showReactionPicker(context, ref, msg.id),
                        );
                      },
                    ),
            ),
            if (typingStatus?.isTyping == true) const TypingIndicator(),
            MessageInput(
              conversationId: conversation?.id ?? 'c1',
              initialDraft: draftText,
              onSend: (text) {
                chatNotifier.sendMessage(text);
                draftNotifier.clearDraft();
              },
            ),
          ],
        ),
      ),
    );
  }
}
