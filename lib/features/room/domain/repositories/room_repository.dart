import 'package:soulsync/features/room/domain/entities/couple_room_entity.dart';
import 'package:soulsync/features/room/domain/entities/listening_session_entity.dart';
import 'package:soulsync/features/room/domain/entities/room_member_entity.dart';

abstract class RoomRepository {
  Future<CoupleRoomEntity> createRoom(String roomName);
  Future<CoupleRoomEntity> joinRoom(String inviteCode);
  Future<void> leaveRoom(String roomId);
  Future<CoupleRoomEntity?> getCurrentRoom();
  Future<ListeningSessionEntity> startListeningSession(String roomId);
  Future<void> endListeningSession(String roomId);
  Future<List<RoomMemberEntity>> getRoomMembers(String roomId);
  Stream<ListeningSessionEntity> watchListeningSession(String roomId);
  Stream<List<RoomMemberEntity>> watchRoomMembers(String roomId);
}
