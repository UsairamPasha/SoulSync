import 'package:soulsync/features/chat/domain/entities/conversation_entity.dart';
import 'package:soulsync/features/chat/domain/repositories/chat_repository.dart';

class LoadConversationUseCase {
  final ChatRepository _repository;

  const LoadConversationUseCase(this._repository);

  Future<ConversationEntity> call() async {
    return await _repository.getConversation();
  }
}
