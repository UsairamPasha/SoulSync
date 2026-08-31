from channels.db import database_sync_to_async
from django.utils import timezone

class HeartbeatService:
    @staticmethod
    @database_sync_to_async
    def process_heartbeat(user):
        if user and user.is_authenticated:
            user.is_online = True
            user.last_seen = timezone.now()
            user.save(update_fields=['is_online', 'last_seen'])
            return {
                'status': 'acknowledged',
                'timestamp': timezone.now().isoformat(),
            }
        return {'status': 'unauthenticated'}
