import 'package:soulsync/features/room/domain/entities/couple_room_entity.dart';
import 'package:soulsync/features/room/domain/repositories/room_repository.dart';

class CreateRoomUseCase {
  final RoomRepository _repository;

  const CreateRoomUseCase(this._repository);

  Future<CoupleRoomEntity> call(String roomName) async {
    return await _repository.createRoom(roomName);
  }
}
