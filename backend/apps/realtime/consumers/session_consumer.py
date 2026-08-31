import json
from channels.generic.websocket import AsyncWebsocketConsumer

class SessionConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.user = self.scope.get('user')
        if not self.user or not self.user.is_authenticated:
            await self.close()
            return

        self.session_group = "session_sync_default"
        await self.channel_layer.group_add(self.session_group, self.channel_name)
        await self.accept()

        await self.send(text_data=json.dumps({
            'type': 'session_connected',
            'status': 'ready',
        }))

    async def disconnect(self, close_code):
        if hasattr(self, 'session_group'):
            await self.channel_layer.group_discard(self.session_group, self.channel_name)

    async def receive(self, text_data=None, bytes_data=None):
        if not text_data:
            return
        data = json.loads(text_data)
        await self.channel_layer.group_send(
            self.session_group,
            {
                'type': 'session_state_update',
                'state': data,
                'senderId': str(self.user.id),
            },
        )

    async def session_state_update(self, event):
        await self.send(text_data=json.dumps(event))
