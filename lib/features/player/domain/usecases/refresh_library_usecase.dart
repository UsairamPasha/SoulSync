import 'package:soulsync/features/player/domain/entities/song_entity.dart';
import 'package:soulsync/features/player/domain/repositories/music_repository.dart';

class RefreshLibraryUseCase {
  final MusicRepository _repository;

  const RefreshLibraryUseCase(this._repository);

  Future<List<SongEntity>> call() async {
    return await _repository.refreshLibrary();
  }
}
