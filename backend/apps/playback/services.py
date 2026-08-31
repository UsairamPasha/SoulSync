import logging
from asgiref.sync import async_to_sync
from channels.layers import get_channel_layer
from django.utils import timezone
from apps.relationships.models import CoupleRelationship
from apps.playback.models import PlaybackSession, PlaybackStateChoices

logger = logging.getLogger(__name__)

class PlaybackSynchronizationService:
    @staticmethod
    def broadcast_playback_event(event_type, session, user=None, extra_payload=None):
        try:
            channel_layer = get_channel_layer()
            if not channel_layer:
                return

            payload = {
                'type': event_type,
                'event': event_type,
                'sessionId': str(session.id),
                'roomId': session.room_id,
                'hostId': str(session.host_user.id),
                'senderId': str(user.id) if user else str(session.host_user.id),
                'currentSongId': session.current_song_id,
                'playbackState': session.playback_state,
                'positionMs': session.playback_position_ms,
                'durationMs': session.duration_ms,
                'timestamp': timezone.now().isoformat(),
            }
            if extra_payload:
                payload.update(extra_payload)

            print(f"[DIAGNOSTIC-BE] REST API broadcast_playback_event '{event_type}' for session {session.id} (host: {session.host_user.id})")
            # Broadcast to host group
            async_to_sync(channel_layer.group_send)(
                f"user_{session.host_user.id}",
                payload,
            )

            # Broadcast to partner group if partner exists
            rel = CoupleRelationship.get_user_relationship(session.host_user)
            if rel:
                partner = rel.get_partner(session.host_user)
                if partner:
                    print(f"[DIAGNOSTIC-BE] REST API broadcasting '{event_type}' to partner group user_{partner.id}")
                    async_to_sync(channel_layer.group_send)(
                        f"user_{partner.id}",
                        payload,
                    )
            logger.info(f"[PlaybackSync] Broadcasted event '{event_type}' for session {session.id}")
        except Exception as e:
            logger.error(f"[PlaybackSync] Error broadcasting event '{event_type}': {e}")

class PlaybackService:
    @staticmethod
    def start_session(user, room_id='soul_sync_room_default'):
        # Validate that user is in a couple relationship
        rel = CoupleRelationship.get_user_relationship(user)
        if not rel:
            raise PermissionError("You must be in a couple relationship to start a listening session.")

        # Deactivate any existing active sessions for this user/room
        PlaybackSession.objects.filter(room_id=room_id, is_active=True).update(
            is_active=False,
            playback_state=PlaybackStateChoices.SESSION_ENDED,
        )

        session = PlaybackSession.objects.create(
            room_id=room_id,
            host_user=user,
            playback_state=PlaybackStateChoices.READY,
            started_at=timezone.now(),
            is_active=True,
        )

        PlaybackSynchronizationService.broadcast_playback_event('session_started', session, user=user)
        return session

    @staticmethod
    def get_active_session(user):
        rel = CoupleRelationship.get_user_relationship(user)
        if not rel:
            return None
        partner = rel.get_partner(user)

        session = PlaybackSession.objects.filter(
            is_active=True,
            host_user__in=[user, partner] if partner else [user],
        ).first()
        return session

    @staticmethod
    def play(user, position_ms=0, song_id=None):
        session = PlaybackService.get_active_session(user)
        if not session:
            raise ValueError("No active playback session found.")

        session.playback_state = PlaybackStateChoices.PLAYING
        session.playback_position_ms = position_ms
        if song_id:
            session.current_song_id = song_id
        session.save()

        PlaybackSynchronizationService.broadcast_playback_event('play', session, user=user)
        return session

    @staticmethod
    def pause(user, position_ms=0):
        session = PlaybackService.get_active_session(user)
        if not session:
            raise ValueError("No active playback session found.")

        session.playback_state = PlaybackStateChoices.PAUSED
        session.playback_position_ms = position_ms
        session.save()

        PlaybackSynchronizationService.broadcast_playback_event('pause', session, user=user)
        return session

    @staticmethod
    def resume(user, position_ms=0):
        session = PlaybackService.get_active_session(user)
        if not session:
            raise ValueError("No active playback session found.")

        session.playback_state = PlaybackStateChoices.PLAYING
        session.playback_position_ms = position_ms
        session.save()

        PlaybackSynchronizationService.broadcast_playback_event('resume', session, user=user)
        return session

    @staticmethod
    def seek(user, position_ms=0, song_id=None):
        session = PlaybackService.get_active_session(user)
        if not session:
            raise ValueError("No active playback session found.")

        session.playback_position_ms = position_ms
        if song_id:
            session.current_song_id = song_id
        session.save()

        PlaybackSynchronizationService.broadcast_playback_event('seek_changed', session, user=user, extra_payload={
            'position_ms': position_ms,
            'song_id': session.current_song_id,
        })
        return session

    @staticmethod
    def heartbeat(user, position_ms=0, playing=True, queue_index=0, song_id=None):
        session = PlaybackService.get_active_session(user)
        if not session:
            return None

        session.playback_position_ms = position_ms
        if playing:
            session.playback_state = PlaybackStateChoices.PLAYING
        if song_id:
            session.current_song_id = song_id
        session.save(update_fields=['playback_position_ms', 'playback_state', 'current_song_id', 'updated_at'])

        PlaybackSynchronizationService.broadcast_playback_event('playback_state', session, user=user, extra_payload={
            'position_ms': position_ms,
            'playing': playing,
            'queue_index': queue_index,
            'song_id': session.current_song_id,
        })
        return session

    @staticmethod
    def end_session(user):
        session = PlaybackService.get_active_session(user)
        if not session:
            return None

        if session.host_user != user:
            raise PermissionError("Only the Room Host can end the listening session.")

        session.playback_state = PlaybackStateChoices.SESSION_ENDED
        session.is_active = False
        session.save()

        PlaybackSynchronizationService.broadcast_playback_event('session_ended', session, user=user)
        return session
