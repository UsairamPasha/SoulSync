import 'package:soulsync/features/room/domain/entities/listening_session_entity.dart';
import 'package:soulsync/features/room/domain/repositories/room_repository.dart';

class StartListeningSessionUseCase {
  final RoomRepository _repository;

  const StartListeningSessionUseCase(this._repository);

  Future<ListeningSessionEntity> call(String roomId) async {
    return await _repository.startListeningSession(roomId);
  }
}
