import 'package:soulsync/features/player/domain/entities/album_entity.dart';
import 'package:soulsync/features/player/domain/repositories/music_repository.dart';

class GetAlbumsUseCase {
  final MusicRepository _repository;

  const GetAlbumsUseCase(this._repository);

  Future<List<AlbumEntity>> call() async {
    return await _repository.getAlbums();
  }
}
