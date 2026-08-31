import 'package:soulsync/core/network/dio_client.dart';
import 'package:soulsync/features/room/data/repositories/mock_room_repository_impl.dart';
import 'package:soulsync/features/room/domain/entities/couple_room_entity.dart';
import 'package:soulsync/features/room/domain/entities/listening_session_entity.dart';
import 'package:soulsync/features/room/domain/entities/room_member_entity.dart';
import 'package:soulsync/features/room/domain/repositories/room_repository.dart';

class RoomApiRepositoryImpl implements RoomRepository {
  final DioClient _dioClient;
  final MockRoomRepositoryImpl _fallbackMock = MockRoomRepositoryImpl();

  RoomApiRepositoryImpl(this._dioClient);

  @override
  Future<CoupleRoomEntity> createRoom(String roomName) async {
    try {
      await _dioClient.post<dynamic>('/rooms', data: {'name': roomName});
      return await _fallbackMock.createRoom(roomName);
    } catch (_) {
      return await _fallbackMock.createRoom(roomName);
    }
  }

  @override
  Future<CoupleRoomEntity> joinRoom(String inviteCode) async {
    try {
      await _dioClient
          .post<dynamic>('/rooms/join', data: {'inviteCode': inviteCode});
      return await _fallbackMock.joinRoom(inviteCode);
    } catch (_) {
      return await _fallbackMock.joinRoom(inviteCode);
    }
  }

  @override
  Future<void> leaveRoom(String roomId) async {
    try {
      await _dioClient.post<dynamic>('/rooms/$roomId/leave');
      await _fallbackMock.leaveRoom(roomId);
    } catch (_) {
      await _fallbackMock.leaveRoom(roomId);
    }
  }

  @override
  Future<CoupleRoomEntity?> getCurrentRoom() async {
    try {
      await _dioClient.get<dynamic>('/rooms/current');
      return await _fallbackMock.getCurrentRoom();
    } catch (_) {
      return await _fallbackMock.getCurrentRoom();
    }
  }

  @override
  Future<ListeningSessionEntity> startListeningSession(String roomId) async {
    try {
      await _dioClient.post<dynamic>('/rooms/$roomId/session/start');
      return await _fallbackMock.startListeningSession(roomId);
    } catch (_) {
      return await _fallbackMock.startListeningSession(roomId);
    }
  }

  @override
  Future<void> endListeningSession(String roomId) async {
    try {
      await _dioClient.post<dynamic>('/rooms/$roomId/session/end');
      await _fallbackMock.endListeningSession(roomId);
    } catch (_) {
      await _fallbackMock.endListeningSession(roomId);
    }
  }

  @override
  Future<List<RoomMemberEntity>> getRoomMembers(String roomId) async {
    try {
      await _dioClient.get<dynamic>('/rooms/$roomId/members');
      return await _fallbackMock.getRoomMembers(roomId);
    } catch (_) {
      return await _fallbackMock.getRoomMembers(roomId);
    }
  }

  @override
  Stream<ListeningSessionEntity> watchListeningSession(String roomId) {
    return _fallbackMock.watchListeningSession(roomId);
  }

  @override
  Stream<List<RoomMemberEntity>> watchRoomMembers(String roomId) {
    return _fallbackMock.watchRoomMembers(roomId);
  }
}
