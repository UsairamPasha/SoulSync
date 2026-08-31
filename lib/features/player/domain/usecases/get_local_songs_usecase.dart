import 'package:soulsync/features/player/domain/entities/song_entity.dart';
import 'package:soulsync/features/player/domain/repositories/music_repository.dart';

class GetLocalSongsUseCase {
  final MusicRepository _repository;

  const GetLocalSongsUseCase(this._repository);

  Future<List<SongEntity>> call() async {
    return await _repository.getLocalSongs();
  }
}
