import 'package:soulsync/features/chat/domain/repositories/chat_repository.dart';

class ToggleReactionUseCase {
  final ChatRepository _repository;

  const ToggleReactionUseCase(this._repository);

  Future<void> call(String messageId, String emoji) async {
    await _repository.toggleReaction(messageId, emoji);
  }
}
