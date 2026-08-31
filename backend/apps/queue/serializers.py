from rest_framework import serializers
from apps.queue.models import SharedQueue


class SharedQueueSerializer(serializers.ModelSerializer):
    owner_user_id = serializers.UUIDField(source='owner_user.id', read_only=True)
    length = serializers.SerializerMethodField()
    current_song = serializers.SerializerMethodField()

    class Meta:
        model = SharedQueue
        fields = [
            'id',
            'room_id',
            'current_index',
            'songs',
            'owner_user_id',
            'created_at',
            'updated_at',
            'is_active',
            'length',
            'current_song',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']

    def get_length(self, obj):
        return len(obj.songs or [])

    def get_current_song(self, obj):
        songs = obj.songs or []
        if 0 <= obj.current_index < len(songs):
            return songs[obj.current_index]
        return None


class AddSongSerializer(serializers.Serializer):
    song_id = serializers.CharField(max_length=255)
    title = serializers.CharField(max_length=255, required=False, default='Sample Track')
    artist = serializers.CharField(max_length=255, required=False, default='Artist')
    album = serializers.CharField(max_length=255, required=False, default='Album')
    duration_ms = serializers.IntegerField(required=False, default=180000)
    asset_path = serializers.CharField(max_length=500, required=False, default='')


class ReorderQueueSerializer(serializers.Serializer):
    old_index = serializers.IntegerField(min_value=0)
    new_index = serializers.IntegerField(min_value=0)


class RemoveSongSerializer(serializers.Serializer):
    index = serializers.IntegerField(min_value=0)
