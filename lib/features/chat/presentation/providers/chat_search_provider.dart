import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soulsync/features/chat/domain/entities/message_entity.dart';
import 'package:soulsync/features/chat/presentation/providers/chat_provider.dart';

final chatSearchQueryProvider = StateProvider<String>((ref) => '');

final chatSearchResultsProvider =
    FutureProvider<List<MessageEntity>>((ref) async {
  final query = ref.watch(chatSearchQueryProvider);
  if (query.trim().isEmpty) return [];

  final repo = ref.watch(chatRepositoryProvider);
  return await repo.searchMessages(query);
});
