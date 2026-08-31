import json
from channels.generic.websocket import AsyncWebsocketConsumer
from apps.realtime.services.presence_service import PresenceService

class PresenceConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.user = self.scope.get('user')
        if not self.user or not self.user.is_authenticated:
            await self.close()
            return

        self.user_group = f"user_{self.user.id}"
        await self.channel_layer.group_add(self.user_group, self.channel_name)
        await self.channel_layer.group_add("soul_sync_room_default", self.channel_name)

        await PresenceService.set_user_online(self.user)
        partner = await PresenceService.get_partner_user(self.user)

        await self.accept()

        await self.send(text_data=json.dumps({
            'type': 'connection_established',
            'status': 'connected',
            'userId': str(self.user.id),
        }))

        if partner:
            # 1. Notify partner that this user is online
            partner_group = f"user_{partner.id}"
            await self.channel_layer.group_send(
                partner_group,
                {
                    'type': 'presence_update',
                    'userId': str(self.user.id),
                    'isOnline': True,
                    'lastSeen': self.user.last_seen.isoformat() if self.user.last_seen else None,
                },
            )

            # 2. Immediately send partner's current online status back to this user
            await self.send(text_data=json.dumps({
                'type': 'presence_update',
                'userId': str(partner.id),
                'isOnline': partner.is_online,
                'lastSeen': partner.last_seen.isoformat() if partner.last_seen else None,
            }))

    async def disconnect(self, close_code):
        try:
            if hasattr(self, 'user') and self.user and self.user.is_authenticated:
                print(f"[PresenceConsumer] User disconnected: {self.user.email} (code: {close_code})")
                await PresenceService.set_user_offline(self.user)
                now_iso = self.user.last_seen.isoformat() if hasattr(self.user, 'last_seen') and self.user.last_seen else None

                payload = {
                    'type': 'presence_update',
                    'userId': str(self.user.id),
                    'isOnline': False,
                    'lastSeen': now_iso,
                }

                partner = await PresenceService.get_partner_user(self.user)
                if partner:
                    partner_group = f"user_{partner.id}"
                    print(f"[PresenceConsumer] Broadcasting offline status for {self.user.id} to partner group {partner_group}")
                    await self.channel_layer.group_send(partner_group, payload)

                await self.channel_layer.group_send("soul_sync_room_default", payload)

                if hasattr(self, 'user_group'):
                    await self.channel_layer.group_discard(self.user_group, self.channel_name)
                await self.channel_layer.group_discard("soul_sync_room_default", self.channel_name)
        except Exception as e:
            print(f"[PresenceConsumer] Error in disconnect: {e}")

    async def receive(self, text_data=None, bytes_data=None):
        if not text_data or not hasattr(self, 'user') or not self.user or not self.user.is_authenticated:
            return
        try:
            data = json.loads(text_data)
        except Exception:
            return

        payload = {
            'type': 'forward_event',
            'event_data': data,
            'senderId': str(self.user.id),
        }

        partner = await PresenceService.get_partner_user(self.user)
        if partner:
            partner_group = f"user_{partner.id}"
            print(f"[PresenceConsumer] Forwarding WS event '{data.get('type') or data.get('event')}' to partner_group {partner_group}")
            await self.channel_layer.group_send(partner_group, payload)
        
        await self.channel_layer.group_send("soul_sync_room_default", payload)

    async def forward_event(self, event):
        event_data = event.get('event_data', {})
        sender_id = event.get('senderId')
        if sender_id and isinstance(event_data, dict):
            event_data['senderId'] = sender_id
            event_data['sender_id'] = sender_id
        await self.send(text_data=json.dumps(event_data))

    async def presence_update(self, event):
        await self.send(text_data=json.dumps(event))

    async def relationship_update(self, event):
        await self.send(text_data=json.dumps(event))

    async def room_update(self, event):
        await self.send(text_data=json.dumps(event))

    async def room_message(self, event):
        await self.send(text_data=json.dumps(event))

    async def partner_joined(self, event):
        await self.send(text_data=json.dumps(event))

    async def session_started(self, event):
        await self.send(text_data=json.dumps(event))

    async def play(self, event):
        await self.send(text_data=json.dumps(event))

    async def pause(self, event):
        await self.send(text_data=json.dumps(event))

    async def resume(self, event):
        await self.send(text_data=json.dumps(event))

    async def playback_state(self, event):
        await self.send(text_data=json.dumps(event))

    async def session_ended(self, event):
        await self.send(text_data=json.dumps(event))

    async def seek_changed(self, event):
        await self.send(text_data=json.dumps(event))

    async def sync_request(self, event):
        await self.send(text_data=json.dumps(event))

    async def sync_response(self, event):
        await self.send(text_data=json.dumps(event))

    async def heartbeat(self, event):
        await self.send(text_data=json.dumps(event))

    async def playback_settings(self, event):
        await self.send(text_data=json.dumps(event))

    async def room_closed(self, event):
        await self.send(text_data=json.dumps(event))

    async def queue_updated(self, event):
        await self.send(text_data=json.dumps(event))

    async def forward_event(self, event):
        payload = dict(event.get('event_data', {}))
        if 'senderId' not in payload and 'senderId' in event:
            payload['senderId'] = event['senderId']
        await self.send(text_data=json.dumps(payload))

