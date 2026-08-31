import 'package:soulsync/features/player/domain/entities/song_entity.dart';
import 'package:soulsync/features/queue/domain/entities/shared_queue_entity.dart';

abstract class QueueRepository {
  Future<SharedQueueEntity?> getQueue(String roomId);
  Future<SharedQueueEntity?> addSong(String roomId, SongEntity song);
  Future<SharedQueueEntity?> playNext(String roomId, SongEntity song);
  Future<SharedQueueEntity?> reorderQueue(String roomId, int oldIndex, int newIndex);
  Future<SharedQueueEntity?> removeSong(String roomId, int index);
  Future<SharedQueueEntity?> clearQueue(String roomId);
  Future<SharedQueueEntity?> selectSongIndex(String roomId, int index);
  Future<void> syncQueue(String roomId);
}
