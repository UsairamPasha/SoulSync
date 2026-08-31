import uuid
from django.conf import settings
from django.db import models


class SharedQueue(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    room_id = models.CharField(max_length=255, db_index=True)
    current_index = models.PositiveIntegerField(default=0)
    songs = models.JSONField(default=list, blank=True)
    owner_user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='owned_queues',
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    is_active = models.BooleanField(default=True, db_index=True)

    class Meta:
        ordering = ['-updated_at']
        verbose_name = 'Shared Queue'
        verbose_name_plural = 'Shared Queues'

    def __str__(self):
        return f"SharedQueue({self.id}) - Room {self.room_id} [Index: {self.current_index}, Songs: {len(self.songs)}]"
