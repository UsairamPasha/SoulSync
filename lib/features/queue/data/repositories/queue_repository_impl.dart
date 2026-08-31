import 'package:flutter/foundation.dart';
import 'package:soulsync/core/network/dio_client.dart';
import 'package:soulsync/features/player/domain/entities/song_entity.dart';
import 'package:soulsync/features/queue/data/models/shared_queue_model.dart';
import 'package:soulsync/features/queue/domain/entities/shared_queue_entity.dart';
import 'package:soulsync/features/queue/domain/repositories/queue_repository.dart';

class QueueRepositoryImpl implements QueueRepository {
  final DioClient _dioClient;

  QueueRepositoryImpl(this._dioClient);

  @override
  Future<SharedQueueEntity?> getQueue(String roomId) async {
    try {
      final response = await _dioClient.get<Map<String, dynamic>>(
        '/queue/',
        queryParameters: {'room_id': roomId},
      );
      if (response.data != null && response.data!['data'] != null) {
        return SharedQueueModel.fromJson(response.data!['data'] as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('[QueueRepo] getQueue warning: $e');
    }
    return _getFallbackQueue(roomId);
  }

  @override
  Future<SharedQueueEntity?> addSong(String roomId, SongEntity song) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        '/queue/add/',
        data: {
          'room_id': roomId,
          'song_id': song.id,
          'title': song.title,
          'artist': song.artist,
          'album': song.album,
          'duration_ms': song.duration.inMilliseconds,
          'asset_path': song.assetPath,
        },
      );
      if (response.data != null && response.data!['data'] != null) {
        return SharedQueueModel.fromJson(response.data!['data'] as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('[QueueRepo] addSong error: $e');
    }
    return null;
  }

  @override
  Future<SharedQueueEntity?> playNext(String roomId, SongEntity song) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        '/queue/play-next/',
        data: {
          'room_id': roomId,
          'song_id': song.id,
          'title': song.title,
          'artist': song.artist,
          'album': song.album,
          'duration_ms': song.duration.inMilliseconds,
          'asset_path': song.assetPath,
        },
      );
      if (response.data != null && response.data!['data'] != null) {
        return SharedQueueModel.fromJson(response.data!['data'] as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('[QueueRepo] playNext error: $e');
    }
    return null;
  }

  @override
  Future<SharedQueueEntity?> reorderQueue(String roomId, int oldIndex, int newIndex) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        '/queue/reorder/',
        data: {
          'room_id': roomId,
          'old_index': oldIndex,
          'new_index': newIndex,
        },
      );
      if (response.data != null && response.data!['data'] != null) {
        return SharedQueueModel.fromJson(response.data!['data'] as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('[QueueRepo] reorderQueue error: $e');
    }
    return null;
  }

  @override
  Future<SharedQueueEntity?> removeSong(String roomId, int index) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        '/queue/remove/',
        data: {
          'room_id': roomId,
          'index': index,
        },
      );
      if (response.data != null && response.data!['data'] != null) {
        return SharedQueueModel.fromJson(response.data!['data'] as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('[QueueRepo] removeSong error: $e');
    }
    return null;
  }

  @override
  Future<SharedQueueEntity?> clearQueue(String roomId) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        '/queue/clear/',
        data: {'room_id': roomId},
      );
      if (response.data != null && response.data!['data'] != null) {
        return SharedQueueModel.fromJson(response.data!['data'] as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('[QueueRepo] clearQueue error: $e');
    }
    return null;
  }

  @override
  Future<SharedQueueEntity?> selectSongIndex(String roomId, int index) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        '/queue/select/',
        data: {
          'room_id': roomId,
          'index': index,
        },
      );
      if (response.data != null && response.data!['data'] != null) {
        return SharedQueueModel.fromJson(response.data!['data'] as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('[QueueRepo] selectSongIndex error: $e');
    }
    return null;
  }

  @override
  Future<void> syncQueue(String roomId) async {
    try {
      await _dioClient.post<Map<String, dynamic>>(
        '/queue/sync/',
        data: {'room_id': roomId},
      );
    } catch (e) {
      debugPrint('[QueueRepo] syncQueue warning: $e');
    }
  }

  SharedQueueEntity _getFallbackQueue(String roomId) {
    return SharedQueueEntity(
      id: 'queue_fallback',
      roomId: roomId,
      currentIndex: 0,
      songs: const [
        SongEntity(
          id: 'song_1',
          title: 'Sample 1',
          artist: 'SoulSync Audio',
          album: 'SoulSync Essentials',
          duration: Duration(minutes: 3),
          assetPath: 'assets/music/sample_1.mp3',
        ),
        SongEntity(
          id: 'song_2',
          title: 'Sample 2',
          artist: 'SoulSync Audio',
          album: 'SoulSync Essentials',
          duration: Duration(minutes: 3),
          assetPath: 'assets/music/sample_2.mp3',
        ),
        SongEntity(
          id: 'song_3',
          title: 'Sample 3',
          artist: 'SoulSync Audio',
          album: 'SoulSync Essentials',
          duration: Duration(minutes: 3),
          assetPath: 'assets/music/sample_3.mp3',
        ),
      ],
    );
  }
}
