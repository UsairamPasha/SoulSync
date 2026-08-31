from rest_framework import serializers
from apps.playback.models import PlaybackSession, PlaybackStateChoices

class PlaybackSessionSerializer(serializers.ModelSerializer):
    host_id = serializers.CharField(source='host_user.id', read_only=True)
    host_name = serializers.CharField(source='host_user.get_full_name', read_only=True)

    class Meta:
        model = PlaybackSession
        fields = [
            'id',
            'room_id',
            'host_id',
            'host_name',
            'current_song_id',
            'playback_state',
            'playback_position_ms',
            'duration_ms',
            'started_at',
            'updated_at',
            'is_active',
        ]
        read_only_fields = ['id', 'host_id', 'host_name', 'updated_at']

class PlaybackActionSerializer(serializers.Serializer):
    position_ms = serializers.IntegerField(required=False, default=0)
    song_id = serializers.CharField(required=False, allow_blank=True)
