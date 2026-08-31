import 'package:soulsync/features/player/domain/repositories/music_repository.dart';

class ToggleFavoriteUseCase {
  final MusicRepository _repository;

  const ToggleFavoriteUseCase(this._repository);

  Future<void> call(String songId) async {
    await _repository.toggleFavorite(songId);
  }
}
