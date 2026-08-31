import 'package:soulsync/features/room/domain/entities/couple_room_entity.dart';
import 'package:soulsync/features/room/domain/repositories/room_repository.dart';

class GetCurrentRoomUseCase {
  final RoomRepository _repository;

  const GetCurrentRoomUseCase(this._repository);

  Future<CoupleRoomEntity?> call() async {
    return await _repository.getCurrentRoom();
  }
}
