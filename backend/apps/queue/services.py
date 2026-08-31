import logging
from asgiref.sync import async_to_sync
from channels.layers import get_channel_layer
from apps.queue.models import SharedQueue
from apps.queue.serializers import SharedQueueSerializer

from apps.relationships.models import CoupleRelationship

logger = logging.getLogger(__name__)


class QueueService:

    @staticmethod
    def get_or_create_queue(room_id: str, user) -> SharedQueue:
        queue = SharedQueue.objects.filter(room_id=room_id, is_active=True).first()
        if not queue:
            default_songs = [
                {
                    'id': 'song_1',
                    'title': 'Sample 1',
                    'artist': 'SoulSync Audio',
                    'album': 'SoulSync Essentials',
                    'duration_ms': 180000,
                    'asset_path': 'assets/music/sample_1.mp3',
                    'added_by': str(user.id),
                },
                {
                    'id': 'song_2',
                    'title': 'Sample 2',
                    'artist': 'SoulSync Audio',
                    'album': 'SoulSync Essentials',
                    'duration_ms': 180000,
                    'asset_path': 'assets/music/sample_2.mp3',
                    'added_by': str(user.id),
                },
                {
                    'id': 'song_3',
                    'title': 'Sample 3',
                    'artist': 'SoulSync Audio',
                    'album': 'SoulSync Essentials',
                    'duration_ms': 180000,
                    'asset_path': 'assets/music/sample_3.mp3',
                    'added_by': str(user.id),
                },
            ]
            queue = SharedQueue.objects.create(
                room_id=room_id,
                owner_user=user,
                songs=default_songs,
                current_index=0,
                is_active=True,
            )
            QueueService.broadcast_queue_event(queue, 'queue_created')
        return queue

    @staticmethod
    def add_song(queue: SharedQueue, song_data: dict, user) -> SharedQueue:
        songs = list(queue.songs or [])
        song_entry = {
            'id': song_data.get('song_id') or f"song_{len(songs) + 1}",
            'title': song_data.get('title', 'Sample Track'),
            'artist': song_data.get('artist', 'Artist'),
            'album': song_data.get('album', 'Album'),
            'duration_ms': song_data.get('duration_ms', 180000),
            'asset_path': song_data.get('asset_path') or f"assets/music/{song_data.get('song_id', 'sample_1')}.mp3",
            'added_by': str(user.id),
        }
        songs.append(song_entry)
        queue.songs = songs
        queue.save(update_fields=['songs', 'updated_at'])

        QueueService.broadcast_queue_event(queue, 'queue_added', {'added_song': song_entry})
        return queue

    @staticmethod
    def play_next(queue: SharedQueue, song_data: dict, user) -> SharedQueue:
        songs = list(queue.songs or [])
        song_entry = {
            'id': song_data.get('song_id') or f"song_{len(songs) + 1}",
            'title': song_data.get('title', 'Sample Track'),
            'artist': song_data.get('artist', 'Artist'),
            'album': song_data.get('album', 'Album'),
            'duration_ms': song_data.get('duration_ms', 180000),
            'asset_path': song_data.get('asset_path') or f"assets/music/{song_data.get('song_id', 'sample_1')}.mp3",
            'added_by': str(user.id),
        }

        insert_pos = min(queue.current_index + 1, len(songs))
        songs.insert(insert_pos, song_entry)
        queue.songs = songs
        queue.save(update_fields=['songs', 'updated_at'])

        QueueService.broadcast_queue_event(queue, 'queue_updated', {'inserted_at': insert_pos, 'song': song_entry})
        return queue

    @staticmethod
    def reorder_queue(queue: SharedQueue, old_index: int, new_index: int, user) -> SharedQueue:
        songs = list(queue.songs or [])
        if old_index < 0 or old_index >= len(songs):
            return queue

        if old_index < new_index:
            new_index -= 1
        new_index = max(0, min(new_index, len(songs) - 1))

        item = songs.pop(old_index)
        songs.insert(new_index, item)

        # Adjust current_index if current song was moved
        if queue.current_index == old_index:
            queue.current_index = new_index
        elif old_index < queue.current_index <= new_index:
            queue.current_index -= 1
        elif new_index <= queue.current_index < old_index:
            queue.current_index += 1

        queue.songs = songs
        queue.save(update_fields=['songs', 'current_index', 'updated_at'])

        QueueService.broadcast_queue_event(queue, 'queue_reordered', {
            'old_index': old_index,
            'new_index': new_index,
        })
        return queue

    @staticmethod
    def remove_song(queue: SharedQueue, index: int, user) -> SharedQueue:
        songs = list(queue.songs or [])
        if index < 0 or index >= len(songs):
            return queue

        removed_song = songs.pop(index)

        # Adjust current index & queue state for edge cases
        if len(songs) == 0:
            queue.current_index = 0
        elif index < queue.current_index:
            queue.current_index -= 1
        elif index == queue.current_index:
            if queue.current_index >= len(songs):
                queue.current_index = max(0, len(songs) - 1)

        queue.songs = songs
        queue.save(update_fields=['songs', 'current_index', 'updated_at'])

        QueueService.broadcast_queue_event(queue, 'queue_removed', {
            'removed_index': index,
            'removed_song': removed_song,
        })
        return queue

    @staticmethod
    def clear_queue(queue: SharedQueue, user) -> SharedQueue:
        queue.songs = []
        queue.current_index = 0
        queue.save(update_fields=['songs', 'current_index', 'updated_at'])

        QueueService.broadcast_queue_event(queue, 'queue_cleared')
        return queue

    @staticmethod
    def set_current_index(queue: SharedQueue, index: int, user) -> SharedQueue:
        songs = queue.songs or []
        if 0 <= index < len(songs):
            queue.current_index = index
            queue.save(update_fields=['current_index', 'updated_at'])
            song_entry = songs[index] if index < len(songs) else None
            QueueService.broadcast_queue_event(queue, 'queue_current_changed', {
                'current_index': index,
                'song': song_entry,
            })
        return queue

    @staticmethod
    def broadcast_queue_event(queue: SharedQueue, event_type: str, extra_data: dict = None):
        channel_layer = get_channel_layer()
        if not channel_layer:
            return

        serialized = SharedQueueSerializer(queue).data
        payload = {
            'type': 'queue_updated',
            'event': event_type,
            'queue_id': str(queue.id),
            'room_id': queue.room_id,
            'current_index': queue.current_index,
            'songs': serialized['songs'],
            'timestamp': serialized['updated_at'],
        }
        if extra_data:
            payload.update(extra_data)

        ws_message = {
            'type': 'queue_updated',
            'event': event_type,
            'queue': payload,
        }

        # Broadcast to owner user group
        if queue.owner_user:
            async_to_sync(channel_layer.group_send)(
                f"user_{queue.owner_user.id}",
                ws_message,
            )
            # Broadcast to partner group if partner exists
            rel = CoupleRelationship.get_user_relationship(queue.owner_user)
            if rel:
                partner = rel.get_partner(queue.owner_user)
                if partner:
                    async_to_sync(channel_layer.group_send)(
                        f"user_{partner.id}",
                        ws_message,
                    )

        # Broadcast to default room group
        async_to_sync(channel_layer.group_send)(
            "soul_sync_room_default",
            ws_message,
        )
        logger.info(f"[QueueSync] Broadcasted event '{event_type}' for queue {queue.id} in room {queue.room_id}")
