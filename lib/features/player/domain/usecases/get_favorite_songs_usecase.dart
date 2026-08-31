import 'package:soulsync/features/player/domain/entities/song_entity.dart';
import 'package:soulsync/features/player/domain/repositories/music_repository.dart';

class GetFavoriteSongsUseCase {
  final MusicRepository _repository;

  const GetFavoriteSongsUseCase(this._repository);

  Future<List<SongEntity>> call() async {
    return await _repository.getFavoriteSongs();
  }
}
