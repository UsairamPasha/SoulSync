import 'package:soulsync/features/chat/domain/entities/message_entity.dart';
import 'package:soulsync/features/chat/domain/repositories/chat_repository.dart';

class SearchMessagesUseCase {
  final ChatRepository _repository;

  const SearchMessagesUseCase(this._repository);

  Future<List<MessageEntity>> call(String query) async {
    return await _repository.searchMessages(query);
  }
}
