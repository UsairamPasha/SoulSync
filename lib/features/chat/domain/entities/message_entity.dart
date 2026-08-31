import 'package:flutter/foundation.dart';
import 'package:soulsync/features/chat/domain/entities/attachment_entity.dart';
import 'package:soulsync/features/chat/domain/entities/read_receipt_entity.dart';

@immutable
class MessageEntity {
  final String id;
  final String conversationId;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final MessageStatus status;
  final List<String> reactions;
  final List<AttachmentEntity> attachments;
  final String? replyToMessageId;

  const MessageEntity({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.reactions = const [],
    this.attachments = const [],
    this.replyToMessageId,
  });

  MessageEntity copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? text,
    DateTime? timestamp,
    MessageStatus? status,
    List<String>? reactions,
    List<AttachmentEntity>? attachments,
    String? replyToMessageId,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      reactions: reactions ?? this.reactions,
      attachments: attachments ?? this.attachments,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
    );
  }
}
