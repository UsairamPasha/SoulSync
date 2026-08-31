import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soulsync/features/chat/data/datasources/chat_draft_datasource.dart';

class DraftNotifier extends StateNotifier<String> {
  final ChatDraftDataSource _dataSource;
  final String conversationId;

  DraftNotifier(this._dataSource, this.conversationId) : super('') {
    _load();
  }

  Future<void> _load() async {
    final text = await _dataSource.getDraft(conversationId);
    state = text;
  }

  Future<void> updateDraft(String text) async {
    state = text;
    await _dataSource.saveDraft(conversationId, text);
  }

  Future<void> clearDraft() async {
    state = '';
    await _dataSource.saveDraft(conversationId, '');
  }
}

final chatDraftDataSourceProvider = Provider<ChatDraftDataSource>((ref) {
  return ChatDraftDataSource();
});

final draftNotifierProvider =
    StateNotifierProvider.family<DraftNotifier, String, String>(
        (ref, conversationId) {
  final ds = ref.watch(chatDraftDataSourceProvider);
  return DraftNotifier(ds, conversationId);
});
