import 'package:flutter/foundation.dart';

@immutable
class RoomMemberEntity {
  final String id;
  final String displayName;
  final String? avatarUrl;
  final bool isHost;
  final bool isOnline;
  final String statusMessage;

  const RoomMemberEntity({
    required this.id,
    required this.displayName,
    this.avatarUrl,
    this.isHost = false,
    this.isOnline = true,
    this.statusMessage = 'Listening together',
  });

  RoomMemberEntity copyWith({
    String? id,
    String? displayName,
    String? avatarUrl,
    bool? isHost,
    bool? isOnline,
    String? statusMessage,
  }) {
    return RoomMemberEntity(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isHost: isHost ?? this.isHost,
      isOnline: isOnline ?? this.isOnline,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }
}
