import 'package:soulsync/features/room/domain/repositories/room_repository.dart';

class LeaveRoomUseCase {
  final RoomRepository _repository;

  const LeaveRoomUseCase(this._repository);

  Future<void> call(String roomId) async {
    await _repository.leaveRoom(roomId);
  }
}
