import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:soulsync/core/constants/app_spacing.dart';
import 'package:soulsync/features/chat/presentation/providers/chat_search_provider.dart';
import 'package:soulsync/features/chat/presentation/widgets/chat_bubble.dart';
import 'package:soulsync/shared/widgets/inputs/app_text_field.dart';
import 'package:soulsync/shared/widgets/loading/app_circular_loader.dart';
import 'package:soulsync/shared/widgets/scaffold/app_scaffold.dart';
import 'package:soulsync/shared/widgets/states/app_empty_state.dart';

class ChatSearchScreen extends ConsumerWidget {
  const ChatSearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(chatSearchQueryProvider);
    final searchAsync = ref.watch(chatSearchResultsProvider);

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Search Messages'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: AppSpacing.paddingLG,
              child: AppTextField(
                hintText: 'Search chat history...',
                prefixIcon: const Icon(Icons.search_rounded),
                onChanged: (val) {
                  ref.read(chatSearchQueryProvider.notifier).state = val;
                },
              ),
            ),
            Expanded(
              child: searchAsync.when(
                data: (results) {
                  if (query.trim().isEmpty) {
                    return const AppEmptyState(
                      title: 'Search Conversation',
                      description:
                          'Type keywords above to search your couple message history.',
                      icon: Icons.manage_search_rounded,
                    );
                  }

                  if (results.isEmpty) {
                    return AppEmptyState(
                      title: 'No Messages Found',
                      description: 'No messages match "$query".',
                      icon: Icons.search_off_rounded,
                    );
                  }

                  return ListView.builder(
                    padding: AppSpacing.paddingLG,
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final msg = results[index];
                      return ChatBubble(
                        message: msg,
                        isMe: msg.senderId == 'user_me',
                        onLongPress: () {},
                      );
                    },
                  );
                },
                loading: () => const Center(child: AppCircularLoader()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
