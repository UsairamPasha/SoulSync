import 'dart:async';
import 'dart:math';

import 'package:soulsync/features/room/domain/entities/couple_room_entity.dart';
import 'package:soulsync/features/room/domain/entities/listening_session_entity.dart';
import 'package:soulsync/features/room/domain/entities/room_member_entity.dart';
import 'package:soulsync/features/room/domain/repositories/room_repository.dart';

class MockRoomRepositoryImpl implements RoomRepository {
  CoupleRoomEntity? _currentRoom;
  final List<RoomMemberEntity> _members = [];
  ListeningSessionEntity? _activeSession;

  final StreamController<ListeningSessionEntity> _sessionStreamController =
      StreamController<ListeningSessionEntity>.broadcast();
  final StreamController<List<RoomMemberEntity>> _membersStreamController =
      StreamController<List<RoomMemberEntity>>.broadcast();

  String _generateInviteCode() {
    final random = Random();
    final number = 1000 + random.nextInt(9000);
    return 'SOUL-$number';
  }

  @override
  Future<CoupleRoomEntity> createRoom(String roomName) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final code = _generateInviteCode();

    _currentRoom = CoupleRoomEntity(
      id: 'room_${DateTime.now().millisecondsSinceEpoch}',
      name: roomName,
      inviteCode: code,
      hostUserId: 'user_host_1',
      createdAt: DateTime.now(),
      isPartnerConnected: false,
    );

    _members.clear();
    _members.add(
      const RoomMemberEntity(
        id: 'user_host_1',
        displayName: 'Room Host',
        isHost: true,
        isOnline: true,
        statusMessage: 'Host • Room Created',
      ),
    );
    _membersStreamController.add(List.from(_members));

    return _currentRoom!;
  }

  @override
  Future<CoupleRoomEntity> joinRoom(String inviteCode) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    _currentRoom = CoupleRoomEntity(
      id: 'room_joined_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Couple Room',
      inviteCode: inviteCode.toUpperCase(),
      hostUserId: 'user_host_1',
      partnerUserId: 'user_partner_2',
      createdAt: DateTime.now(),
      isPartnerConnected: true,
    );

    _members.clear();
    _members.addAll([
      const RoomMemberEntity(
        id: 'user_host_1',
        displayName: 'Room Host',
        isHost: true,
        isOnline: true,
        statusMessage: 'Host',
      ),
      const RoomMemberEntity(
        id: 'user_partner_2',
        displayName: 'Partner',
        isHost: false,
        isOnline: true,
        statusMessage: 'Joined via invite code',
      ),
    ]);
    _membersStreamController.add(List.from(_members));

    return _currentRoom!;
  }

  @override
  Future<void> leaveRoom(String roomId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _currentRoom = null;
    _members.clear();
    _activeSession = null;
    _membersStreamController.add([]);
  }

  @override
  Future<CoupleRoomEntity?> getCurrentRoom() async {
    return _currentRoom;
  }

  @override
  Future<ListeningSessionEntity> startListeningSession(String roomId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _activeSession = ListeningSessionEntity(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}',
      roomId: roomId,
      isPlaying: true,
      position: Duration.zero,
      duration: const Duration(seconds: 180),
      syncQuality: SyncQualityState.synced,
      startedAt: DateTime.now(),
    );
    _sessionStreamController.add(_activeSession!);
    return _activeSession!;
  }

  @override
  Future<void> endListeningSession(String roomId) async {
    _activeSession = null;
  }

  @override
  Future<List<RoomMemberEntity>> getRoomMembers(String roomId) async {
    return List.from(_members);
  }

  @override
  Stream<ListeningSessionEntity> watchListeningSession(String roomId) {
    return _sessionStreamController.stream;
  }

  @override
  Stream<List<RoomMemberEntity>> watchRoomMembers(String roomId) {
    return _membersStreamController.stream;
  }

  void dispose() {
    _sessionStreamController.close();
    _membersStreamController.close();
  }
}
