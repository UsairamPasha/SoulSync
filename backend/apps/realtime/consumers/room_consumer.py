import json
from channels.generic.websocket import AsyncWebsocketConsumer

class RoomConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.user = self.scope.get('user')
        if not self.user or not self.user.is_authenticated:
            await self.close()
            return

        self.room_group = "soul_sync_room_default"
        await self.channel_layer.group_add(self.room_group, self.channel_name)
        await self.accept()

        await self.send(text_data=json.dumps({
            'type': 'room_connected',
            'room': 'default_couple_room',
            'userId': str(self.user.id),
        }))

    async def disconnect(self, close_code):
        if hasattr(self, 'room_group'):
            await self.channel_layer.group_discard(self.room_group, self.channel_name)

    async def receive(self, text_data=None, bytes_data=None):
        if not text_data:
            return
        data = json.loads(text_data)
        event_type = data.get('type', 'room_update')

        await self.channel_layer.group_send(
            self.room_group,
            {
                'type': 'room_message',
                'event': event_type,
                'payload': data,
                'senderId': str(self.user.id),
            },
        )

    async def room_message(self, event):
        await self.send(text_data=json.dumps(event))
