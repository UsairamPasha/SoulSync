import json
from channels.generic.websocket import AsyncWebsocketConsumer
from apps.realtime.services.heartbeat_service import HeartbeatService

class HeartbeatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.user = self.scope.get('user')
        if not self.user or not self.user.is_authenticated:
            await self.close()
            return
        await self.accept()

    async def receive(self, text_data=None, bytes_data=None):
        if not text_data:
            return
        result = await HeartbeatService.process_heartbeat(self.user)
        await self.send(text_data=json.dumps({
            'type': 'pong',
            'result': result,
        }))
