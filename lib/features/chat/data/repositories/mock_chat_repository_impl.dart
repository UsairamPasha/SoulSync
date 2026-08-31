import 'dart:async';
import 'package:soulsync/features/chat/domain/entities/conversation_entity.dart';
import 'package:soulsync/features/chat/domain/entities/message_entity.dart';
import 'package:soulsync/features/chat/domain/entities/read_receipt_entity.dart';
import 'package:soulsync/features/chat/domain/entities/typing_status_entity.dart';
import 'package:soulsync/features/chat/domain/repositories/chat_repository.dart';

class MockChatRepositoryImpl implements ChatRepository {
  final List<MessageEntity> _messages = [];
  late ConversationEntity _conversation;
  TypingStatusEntity _typingStatus = TypingStatusEntity(
    userId: 'user_partner_2',
    isTyping: false,
    updatedAt: DateTime.now(),
  );

  final StreamController<List<MessageEntity>> _messagesController =
      StreamController<List<MessageEntity>>.broadcast();
  final StreamController<TypingStatusEntity> _typingController =
      StreamController<TypingStatusEntity>.broadcast();

  final List<Timer> _pendingTimers = [];

  MockChatRepositoryImpl() {
    _initHistory();
  }

  void _initHistory() {
    final now = DateTime.now();

    _conversation = ConversationEntity(
      id: 'c1',
      title: 'My Soulmate',
      partnerId: 'user_partner_2',
      lastMessage: null,
      unreadCount: 0,
      updatedAt: now,
    );
  }

  @override
  Future<ConversationEntity> getConversation() async {
    return _conversation;
  }

  @override
  Future<List<MessageEntity>> getMessages() async {
    return List.from(_messages);
  }

  @override
  Future<MessageEntity> sendMessage(String text) async {
    final now = DateTime.now();
    final newMsg = MessageEntity(
      id: 'msg_${now.millisecondsSinceEpoch}',
      conversationId: 'c1',
      senderId: 'user_me',
      text: text,
      timestamp: now,
      status: MessageStatus.sent,
    );

    _messages.add(newMsg);
    _conversation = _conversation.copyWith(lastMessage: newMsg, updatedAt: now);
    if (!_messagesController.isClosed) {
      _messagesController.add(List.from(_messages));
    }

    return newMsg;
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    _messages.removeWhere((m) => m.id == messageId);
    if (!_messagesController.isClosed) {
      _messagesController.add(List.from(_messages));
    }
  }

  @override
  Future<void> toggleReaction(String messageId, String emoji) async {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      final msg = _messages[index];
      final currentReactions = List<String>.from(msg.reactions);
      if (currentReactions.contains(emoji)) {
        currentReactions.remove(emoji);
      } else {
        currentReactions.add(emoji);
      }
      _messages[index] = msg.copyWith(reactions: currentReactions);
      if (!_messagesController.isClosed) {
        _messagesController.add(List.from(_messages));
      }
    }
  }

  @override
  Future<void> markAsRead() async {
    _conversation = _conversation.copyWith(unreadCount: 0);
  }

  @override
  Future<List<MessageEntity>> searchMessages(String query) async {
    if (query.trim().isEmpty) return [];
    final clean = query.trim().toLowerCase();
    return _messages
        .where((m) => m.text.toLowerCase().contains(clean))
        .toList();
  }

  @override
  Stream<List<MessageEntity>> watchMessages() {
    return _messagesController.stream;
  }

  @override
  Stream<TypingStatusEntity> watchTypingStatus() {
    return _typingController.stream;
  }

  void dispose() {
    for (final timer in _pendingTimers) {
      timer.cancel();
    }
    _pendingTimers.clear();
    _messagesController.close();
    _typingController.close();
  }
}
