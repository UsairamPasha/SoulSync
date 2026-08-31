import 'package:soulsync/features/chat/domain/repositories/chat_repository.dart';

class MarkAsReadUseCase {
  final ChatRepository _repository;

  const MarkAsReadUseCase(this._repository);

  Future<void> call() async {
    await _repository.markAsRead();
  }
}
