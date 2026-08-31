from django.urls import re_path
from apps.realtime.consumers.presence_consumer import PresenceConsumer
from apps.realtime.consumers.room_consumer import RoomConsumer
from apps.realtime.consumers.session_consumer import SessionConsumer
from apps.realtime.consumers.heartbeat_consumer import HeartbeatConsumer

websocket_urlpatterns = [
    re_path(r'^ws/presence/$', PresenceConsumer.as_asgi()),
    re_path(r'^ws/room/$', RoomConsumer.as_asgi()),
    re_path(r'^ws/session/$', SessionConsumer.as_asgi()),
    re_path(r'^ws/heartbeat/$', HeartbeatConsumer.as_asgi()),
]
