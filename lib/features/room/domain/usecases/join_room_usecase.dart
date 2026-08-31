import 'package:soulsync/features/room/domain/entities/couple_room_entity.dart';
import 'package:soulsync/features/room/domain/repositories/room_repository.dart';

class JoinRoomUseCase {
  final RoomRepository _repository;

  const JoinRoomUseCase(this._repository);

  Future<CoupleRoomEntity> call(String inviteCode) async {
    return await _repository.joinRoom(inviteCode);
  }
}
