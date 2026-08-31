import 'package:flutter/foundation.dart';

@immutable
class CoupleRoomEntity {
  final String id;
  final String name;
  final String inviteCode;
  final String hostUserId;
  final String? partnerUserId;
  final DateTime createdAt;
  final bool isPartnerConnected;
  final String? roomArtworkUrl;

  const CoupleRoomEntity({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.hostUserId,
    this.partnerUserId,
    required this.createdAt,
    this.isPartnerConnected = false,
    this.roomArtworkUrl,
  });

  CoupleRoomEntity copyWith({
    String? id,
    String? name,
    String? inviteCode,
    String? hostUserId,
    String? partnerUserId,
    DateTime? createdAt,
    bool? isPartnerConnected,
    String? roomArtworkUrl,
  }) {
    return CoupleRoomEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      inviteCode: inviteCode ?? this.inviteCode,
      hostUserId: hostUserId ?? this.hostUserId,
      partnerUserId: partnerUserId ?? this.partnerUserId,
      createdAt: createdAt ?? this.createdAt,
      isPartnerConnected: isPartnerConnected ?? this.isPartnerConnected,
      roomArtworkUrl: roomArtworkUrl ?? this.roomArtworkUrl,
    );
  }
}
