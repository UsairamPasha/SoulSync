import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:soulsync/features/auth/presentation/providers/auth_provider.dart';
import 'package:soulsync/features/chat/data/repositories/mock_chat_repository_impl.dart';
import 'package:soulsync/features/chat/domain/entities/conversation_entity.dart';
import 'package:soulsync/features/chat/domain/entities/message_entity.dart';
import 'package:soulsync/features/chat/domain/entities/read_receipt_entity.dart';
import 'package:soulsync/features/chat/domain/entities/typing_status_entity.dart';
import 'package:soulsync/features/chat/domain/repositories/chat_repository.dart';
import 'package:soulsync/features/realtime/presentation/providers/realtime_providers.dart';

@immutable
class ChatState {
  final ConversationEntity? conversation;
  final List<MessageEntity> messages;
  final TypingStatusEntity? typingStatus;
  final int unreadCount;
  final bool isLoading;

  const ChatState({
    this.conversation,
    this.messages = const [],
    this.typingStatus,
    this.unreadCount = 0,
    this.isLoading = false,
  });

  ChatState copyWith({
    ConversationEntity? conversation,
    List<MessageEntity>? messages,
    TypingStatusEntity? typingStatus,
    int? unreadCount,
    bool? isLoading,
  }) {
    return ChatState(
      conversation: conversation ?? this.conversation,
      messages: messages ?? this.messages,
      typingStatus: typingStatus ?? this.typingStatus,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final ChatRepository _repository;
  final Ref _ref;
  StreamSubscription<List<MessageEntity>>? _messagesSub;
  StreamSubscription<TypingStatusEntity>? _typingSub;
  StreamSubscription<Map<String, dynamic>>? _wsSub;

  ChatNotifier(this._repository, this._ref) : super(const ChatState()) {
    _load();
  }

  Future<void> _load() async {
    state = state.copyWith(isLoading: true);
    final conv = await _repository.getConversation();
    final msgs = await _repository.getMessages();

    state = state.copyWith(
      conversation: conv,
      messages: msgs,
      isLoading: false,
    );

    _listen();
  }

  void _listen() {
    _messagesSub?.cancel();
    _messagesSub = _repository.watchMessages().listen((msgs) {
      state = state.copyWith(messages: msgs);
    });

    _typingSub?.cancel();
    _typingSub = _repository.watchTypingStatus().listen((status) {
      state = state.copyWith(typingStatus: status);
    });

    _wsSub?.cancel();
    _wsSub = _ref.read(webSocketServiceProvider).messageStream.listen((data) {
      if (data['type'] == 'chat_message') {
        final currentUserId = _ref.read(authNotifierProvider).user?.id ?? 'user_me';
        final senderId = data['senderId'] ?? data['sender_id'];

        // Ignore loopback message sent by self
        if (senderId != null && senderId.toString() == currentUserId.toString()) return;

        final incomingText = data['text'] as String?;
        if (incomingText == null || incomingText.trim().isEmpty) return;

        final incomingMsg = MessageEntity(
          id: data['id']?.toString() ?? 'msg_ws_${DateTime.now().millisecondsSinceEpoch}',
          conversationId: 'c1',
          senderId: senderId?.toString() ?? 'user_partner',
          text: incomingText,
          timestamp: DateTime.tryParse(data['timestamp']?.toString() ?? '') ?? DateTime.now(),
          status: MessageStatus.delivered,
        );

        if (!state.messages.any((m) => m.id == incomingMsg.id)) {
          state = state.copyWith(
            messages: [...state.messages, incomingMsg],
            unreadCount: state.unreadCount + 1,
          );
        }
      }
    });
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    final msg = await _repository.sendMessage(text);

    // Broadcast over WebSocket for cross-device real-time sync
    try {
      final currentUserId = _ref.read(authNotifierProvider).user?.id ?? 'user_me';
      _ref.read(webSocketServiceProvider).send({
        'type': 'chat_message',
        'id': msg.id,
        'text': text.trim(),
        'senderId': currentUserId,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('[ChatNotifier] WS broadcast warning: $e');
    }
  }

  Future<void> deleteMessage(String messageId) async {
    await _repository.deleteMessage(messageId);
  }

  Future<void> toggleReaction(String messageId, String emoji) async {
    await _repository.toggleReaction(messageId, emoji);
  }

  Future<void> markAsRead() async {
    await _repository.markAsRead();
    state = state.copyWith(unreadCount: 0);
  }

  @override
  void dispose() {
    _messagesSub?.cancel();
    _typingSub?.cancel();
    _wsSub?.cancel();
    super.dispose();
  }
}

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return MockChatRepositoryImpl();
});

final chatNotifierProvider =
    StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final repo = ref.watch(chatRepositoryProvider);
  return ChatNotifier(repo, ref);
});
