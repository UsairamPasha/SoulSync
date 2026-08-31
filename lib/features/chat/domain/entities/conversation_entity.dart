import 'package:flutter/foundation.dart';
import 'package:soulsync/features/chat/domain/entities/message_entity.dart';

@immutable
class ConversationEntity {
  final String id;
  final String title;
  final String partnerId;
  final MessageEntity? lastMessage;
  final int unreadCount;
  final DateTime updatedAt;

  const ConversationEntity({
    required this.id,
    required this.title,
    required this.partnerId,
    this.lastMessage,
    this.unreadCount = 0,
    required this.updatedAt,
  });

  ConversationEntity copyWith({
    String? id,
    String? title,
    String? partnerId,
    MessageEntity? lastMessage,
    int? unreadCount,
    DateTime? updatedAt,
  }) {
    return ConversationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      partnerId: partnerId ?? this.partnerId,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
