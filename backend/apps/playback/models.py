import uuid
from django.conf import settings
from django.db import models

class PlaybackStateChoices(models.TextChoices):
    NO_SESSION = 'NO_SESSION', 'No Session'
    SESSION_CREATED = 'SESSION_CREATED', 'Session Created'
    WAITING_FOR_HOST = 'WAITING_FOR_HOST', 'Waiting for Host'
    READY = 'READY', 'Ready'
    PLAYING = 'PLAYING', 'Playing'
    PAUSED = 'PAUSED', 'Paused'
    SESSION_ENDED = 'SESSION_ENDED', 'Session Ended'

class PlaybackSession(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    room_id = models.CharField(max_length=255, db_index=True)
    host_user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='hosted_playback_sessions',
    )
    current_song_id = models.CharField(max_length=255, default='song_1')
    playback_state = models.CharField(
        max_length=50,
        choices=PlaybackStateChoices.choices,
        default=PlaybackStateChoices.READY,
    )
    playback_position_ms = models.PositiveIntegerField(default=0)
    duration_ms = models.PositiveIntegerField(default=0)
    started_at = models.DateTimeField(null=True, blank=True)
    updated_at = models.DateTimeField(auto_now=True)
    is_active = models.BooleanField(default=True, db_index=True)

    class Meta:
        ordering = ['-updated_at']
        verbose_name = 'Playback Session'
        verbose_name_plural = 'Playback Sessions'

    def __str__(self):
        return f"PlaybackSession({self.id}) - Room {self.room_id} [{self.playback_state}]"
