import 'package:soulsync/features/chat/domain/entities/message_entity.dart';
import 'package:soulsync/features/chat/domain/repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository _repository;

  const SendMessageUseCase(this._repository);

  Future<MessageEntity> call(String text) async {
    return await _repository.sendMessage(text);
  }
}
