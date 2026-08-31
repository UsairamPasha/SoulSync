import 'package:soulsync/core/network/dio_client.dart';
import 'package:soulsync/features/chat/data/repositories/mock_chat_repository_impl.dart';
import 'package:soulsync/features/chat/domain/entities/conversation_entity.dart';
import 'package:soulsync/features/chat/domain/entities/message_entity.dart';
import 'package:soulsync/features/chat/domain/entities/typing_status_entity.dart';
import 'package:soulsync/features/chat/domain/repositories/chat_repository.dart';

class ChatApiRepositoryImpl implements ChatRepository {
  final DioClient _dioClient;
  final MockChatRepositoryImpl _fallbackMock = MockChatRepositoryImpl();

  ChatApiRepositoryImpl(this._dioClient);

  @override
  Future<ConversationEntity> getConversation() async {
    try {
      await _dioClient.get<dynamic>('/chat/conversation');
      return await _fallbackMock.getConversation();
    } catch (_) {
      return await _fallbackMock.getConversation();
    }
  }

  @override
  Future<List<MessageEntity>> getMessages() async {
    try {
      await _dioClient.get<dynamic>('/chat/messages');
      return await _fallbackMock.getMessages();
    } catch (_) {
      return await _fallbackMock.getMessages();
    }
  }

  @override
  Future<MessageEntity> sendMessage(String text) async {
    try {
      await _dioClient.post<dynamic>('/chat/messages', data: {'text': text});
      return await _fallbackMock.sendMessage(text);
    } catch (_) {
      return await _fallbackMock.sendMessage(text);
    }
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    try {
      await _dioClient.delete<dynamic>('/chat/messages/$messageId');
      await _fallbackMock.deleteMessage(messageId);
    } catch (_) {
      await _fallbackMock.deleteMessage(messageId);
    }
  }

  @override
  Future<void> toggleReaction(String messageId, String emoji) async {
    try {
      await _dioClient.post<dynamic>('/chat/messages/$messageId/react',
          data: {'emoji': emoji});
      await _fallbackMock.toggleReaction(messageId, emoji);
    } catch (_) {
      await _fallbackMock.toggleReaction(messageId, emoji);
    }
  }

  @override
  Future<void> markAsRead() async {
    try {
      await _dioClient.post<dynamic>('/chat/read');
      await _fallbackMock.markAsRead();
    } catch (_) {
      await _fallbackMock.markAsRead();
    }
  }

  @override
  Future<List<MessageEntity>> searchMessages(String query) async {
    try {
      await _dioClient
          .get<dynamic>('/chat/messages/search', queryParameters: {'q': query});
      return await _fallbackMock.searchMessages(query);
    } catch (_) {
      return await _fallbackMock.searchMessages(query);
    }
  }

  @override
  Stream<List<MessageEntity>> watchMessages() {
    return _fallbackMock.watchMessages();
  }

  @override
  Stream<TypingStatusEntity> watchTypingStatus() {
    return _fallbackMock.watchTypingStatus();
  }
}
