import 'package:dio/dio.dart';
import 'package:soulsync/core/errors/failures.dart';
import 'package:soulsync/core/network/dio_client.dart';
import 'package:soulsync/features/playback/data/models/playback_session_model.dart';
import 'package:soulsync/features/playback/domain/entities/playback_session_entity.dart';
import 'package:soulsync/features/playback/domain/repositories/playback_repository.dart';

class PlaybackApiRepositoryImpl implements PlaybackRepository {
  final DioClient _dioClient;

  PlaybackApiRepositoryImpl(this._dioClient);

  @override
  Future<({Failure? failure, PlaybackSessionEntity? session})> startSession(
      String roomId) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        '/playback/session/start/',
        data: {'roomId': roomId},
      );
      final payload = response.data;
      if (payload != null &&
          payload['success'] == true &&
          payload['data'] != null) {
        final model = PlaybackSessionModel.fromJson(
            payload['data'] as Map<String, dynamic>);
        return (failure: null, session: model);
      }
      return (
        failure: const ServerFailure(message: 'Failed to start session.'),
        session: null
      );
    } on DioException catch (e) {
      return (
        failure: NetworkFailure(message: 'Start session error: ${e.message}'),
        session: null
      );
    } catch (e) {
      return (
        failure: UnknownFailure(message: 'Start session exception: $e'),
        session: null
      );
    }
  }

  @override
  Future<({Failure? failure, PlaybackSessionEntity? session})>
      getCurrentSession() async {
    try {
      final response = await _dioClient.get<Map<String, dynamic>>(
        '/playback/session/current/',
      );
      final payload = response.data;
      if (payload != null &&
          payload['success'] == true &&
          payload['data'] != null) {
        final model = PlaybackSessionModel.fromJson(
            payload['data'] as Map<String, dynamic>);
        return (failure: null, session: model);
      }
      return (failure: null, session: null);
    } catch (e) {
      return (
        failure: NetworkFailure(message: 'Get session error: $e'),
        session: null
      );
    }
  }

  @override
  Future<({Failure? failure, PlaybackSessionEntity? session})> play(
      {int positionMs = 0, String? songId}) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        '/playback/session/play/',
        data: {
          'position_ms': positionMs,
          if (songId != null) 'song_id': songId,
        },
      );
      final payload = response.data;
      if (payload != null &&
          payload['success'] == true &&
          payload['data'] != null) {
        final model = PlaybackSessionModel.fromJson(
            payload['data'] as Map<String, dynamic>);
        return (failure: null, session: model);
      }
      return (
        failure: const ServerFailure(message: 'Play action failed.'),
        session: null
      );
    } catch (e) {
      return (
        failure: NetworkFailure(message: 'Play error: $e'),
        session: null
      );
    }
  }

  @override
  Future<({Failure? failure, PlaybackSessionEntity? session})> pause(
      {int positionMs = 0}) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        '/playback/session/pause/',
        data: {'position_ms': positionMs},
      );
      final payload = response.data;
      if (payload != null &&
          payload['success'] == true &&
          payload['data'] != null) {
        final model = PlaybackSessionModel.fromJson(
            payload['data'] as Map<String, dynamic>);
        return (failure: null, session: model);
      }
      return (
        failure: const ServerFailure(message: 'Pause action failed.'),
        session: null
      );
    } catch (e) {
      return (
        failure: NetworkFailure(message: 'Pause error: $e'),
        session: null
      );
    }
  }

  @override
  Future<({Failure? failure, PlaybackSessionEntity? session})> resume(
      {int positionMs = 0}) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        '/playback/session/resume/',
        data: {'position_ms': positionMs},
      );
      final payload = response.data;
      if (payload != null &&
          payload['success'] == true &&
          payload['data'] != null) {
        final model = PlaybackSessionModel.fromJson(
            payload['data'] as Map<String, dynamic>);
        return (failure: null, session: model);
      }
      return (
        failure: const ServerFailure(message: 'Resume action failed.'),
        session: null
      );
    } catch (e) {
      return (
        failure: NetworkFailure(message: 'Resume error: $e'),
        session: null
      );
    }
  }

  @override
  Future<({Failure? failure, PlaybackSessionEntity? session})> seek(
      {int positionMs = 0, String? songId}) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        '/playback/session/seek/',
        data: {
          'position_ms': positionMs,
          if (songId != null) 'song_id': songId,
        },
      );
      final payload = response.data;
      if (payload != null &&
          payload['success'] == true &&
          payload['data'] != null) {
        final model = PlaybackSessionModel.fromJson(
            payload['data'] as Map<String, dynamic>);
        return (failure: null, session: model);
      }
      return (
        failure: const ServerFailure(message: 'Seek action failed.'),
        session: null
      );
    } catch (e) {
      return (
        failure: NetworkFailure(message: 'Seek error: $e'),
        session: null
      );
    }
  }

  @override
  Future<({Failure? failure, PlaybackSessionEntity? session})> sendHeartbeat(
      {int positionMs = 0, bool playing = true, int queueIndex = 0, String? songId}) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        '/playback/session/state/',
        data: {
          'position_ms': positionMs,
          'playing': playing,
          'queue_index': queueIndex,
          if (songId != null) 'song_id': songId,
        },
      );
      final payload = response.data;
      if (payload != null &&
          payload['success'] == true &&
          payload['data'] != null) {
        final model = PlaybackSessionModel.fromJson(
            payload['data'] as Map<String, dynamic>);
        return (failure: null, session: model);
      }
      return (failure: null, session: null);
    } catch (e) {
      return (
        failure: NetworkFailure(message: 'Heartbeat error: $e'),
        session: null
      );
    }
  }

  @override
  Future<Failure?> endSession() async {
    try {
      await _dioClient.post<Map<String, dynamic>>('/playback/session/end/');
      return null;
    } catch (e) {
      return NetworkFailure(message: 'End session error: $e');
    }
  }
}
