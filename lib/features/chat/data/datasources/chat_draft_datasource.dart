import 'package:shared_preferences/shared_preferences.dart';

class ChatDraftDataSource {
  static const _keyPrefix = 'soulsync_chat_draft_';

  Future<String> getDraft(String conversationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('$_keyPrefix$conversationId') ?? '';
    } catch (_) {
      return '';
    }
  }

  Future<void> saveDraft(String conversationId, String draft) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (draft.trim().isEmpty) {
        await prefs.remove('$_keyPrefix$conversationId');
      } else {
        await prefs.setString('$_keyPrefix$conversationId', draft);
      }
    } catch (_) {}
  }
}
