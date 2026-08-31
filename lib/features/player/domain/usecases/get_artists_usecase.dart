import 'package:soulsync/features/player/domain/entities/artist_entity.dart';
import 'package:soulsync/features/player/domain/repositories/music_repository.dart';

class GetArtistsUseCase {
  final MusicRepository _repository;

  const GetArtistsUseCase(this._repository);

  Future<List<ArtistEntity>> call() async {
    return await _repository.getArtists();
  }
}
