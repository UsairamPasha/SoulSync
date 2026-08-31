import 'package:soulsync/features/player/domain/entities/song_entity.dart';
import 'package:soulsync/features/player/domain/repositories/music_repository.dart';

class SearchSongsUseCase {
  final MusicRepository _repository;

  const SearchSongsUseCase(this._repository);

  Future<List<SongEntity>> call(String query) async {
    return await _repository.searchSongs(query);
  }
}
