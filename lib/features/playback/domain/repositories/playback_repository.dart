import 'package:soulsync/core/errors/failures.dart';
import 'package:soulsync/features/playback/domain/entities/playback_session_entity.dart';

abstract class PlaybackRepository {
  Future<({Failure? failure, PlaybackSessionEntity? session})> startSession(
      String roomId);
  Future<({Failure? failure, PlaybackSessionEntity? session})>
      getCurrentSession();
  Future<({Failure? failure, PlaybackSessionEntity? session})> play(
      {int positionMs = 0, String? songId});
  Future<({Failure? failure, PlaybackSessionEntity? session})> pause(
      {int positionMs = 0});
  Future<({Failure? failure, PlaybackSessionEntity? session})> resume(
      {int positionMs = 0});
  Future<({Failure? failure, PlaybackSessionEntity? session})> seek(
      {int positionMs = 0, String? songId});
  Future<({Failure? failure, PlaybackSessionEntity? session})> sendHeartbeat(
      {int positionMs = 0, bool playing = true, int queueIndex = 0, String? songId});
  Future<Failure?> endSession();
}
