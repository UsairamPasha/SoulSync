from channels.db import database_sync_to_async
from django.utils import timezone
from apps.relationships.models import CoupleRelationship

class PresenceService:
    @staticmethod
    @database_sync_to_async
    def set_user_online(user):
        if user and user.is_authenticated:
            user.is_online = True
            user.last_seen = timezone.now()
            user.save(update_fields=['is_online', 'last_seen'])

    @staticmethod
    @database_sync_to_async
    def set_user_offline(user):
        if user and user.is_authenticated:
            user.is_online = False
            user.last_seen = timezone.now()
            user.save(update_fields=['is_online', 'last_seen'])

    @staticmethod
    @database_sync_to_async
    def get_partner_user(user):
        if not user or not user.is_authenticated:
            return None
        rel = CoupleRelationship.get_user_relationship(user)
        if rel:
            return rel.get_partner(user)
        return None
