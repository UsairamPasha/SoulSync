import 'package:soulsync/features/chat/domain/entities/conversation_entity.dart';
import 'package:soulsync/features/chat/domain/entities/message_entity.dart';
import 'package:soulsync/features/chat/domain/entities/typing_status_entity.dart';

abstract class ChatRepository {
  Future<ConversationEntity> getConversation();
  Future<List<MessageEntity>> getMessages();
  Future<MessageEntity> sendMessage(String text);
  Future<void> deleteMessage(String messageId);
  Future<void> toggleReaction(String messageId, String emoji);
  Future<void> markAsRead();
  Future<List<MessageEntity>> searchMessages(String query);
  Stream<List<MessageEntity>> watchMessages();
  Stream<TypingStatusEntity> watchTypingStatus();
}
