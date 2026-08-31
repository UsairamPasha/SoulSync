from django.urls import path
from apps.queue.views import (
    SharedQueueDetailView,
    AddSongView,
    PlayNextView,
    ReorderQueueView,
    RemoveSongView,
    ClearQueueView,
    SyncQueueView,
    SelectSongView,
)

urlpatterns = [
    path('', SharedQueueDetailView.as_view(), name='queue_detail'),
    path('add/', AddSongView.as_view(), name='queue_add'),
    path('play-next/', PlayNextView.as_view(), name='queue_play_next'),
    path('reorder/', ReorderQueueView.as_view(), name='queue_reorder'),
    path('remove/', RemoveSongView.as_view(), name='queue_remove'),
    path('clear/', ClearQueueView.as_view(), name='queue_clear'),
    path('sync/', SyncQueueView.as_view(), name='queue_sync'),
    path('select/', SelectSongView.as_view(), name='queue_select'),
]
