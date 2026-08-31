from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from drf_spectacular.utils import extend_schema

from apps.queue.serializers import (
    SharedQueueSerializer,
    AddSongSerializer,
    ReorderQueueSerializer,
    RemoveSongSerializer,
)
from apps.queue.services import QueueService


class SharedQueueDetailView(APIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(responses={200: SharedQueueSerializer})
    def get(self, request):
        room_id = request.query_params.get('room_id') or 'soul_sync_room_default'
        queue = QueueService.get_or_create_queue(room_id, request.user)
        serializer = SharedQueueSerializer(queue)
        return Response(
            {
                'success': True,
                'data': serializer.data,
            },
            status=status.HTTP_200_OK,
        )


class AddSongView(APIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(request=AddSongSerializer, responses={200: SharedQueueSerializer})
    def post(self, request):
        serializer = AddSongSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(
                {'success': False, 'errors': serializer.errors},
                status=status.HTTP_400_BAD_REQUEST,
            )
        room_id = request.data.get('room_id') or 'soul_sync_room_default'
        queue = QueueService.get_or_create_queue(room_id, request.user)
        updated_queue = QueueService.add_song(queue, serializer.validated_data, request.user)
        return Response(
            {
                'success': True,
                'message': 'Song added to shared queue.',
                'data': SharedQueueSerializer(updated_queue).data,
            },
            status=status.HTTP_200_OK,
        )


class PlayNextView(APIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(request=AddSongSerializer, responses={200: SharedQueueSerializer})
    def post(self, request):
        serializer = AddSongSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(
                {'success': False, 'errors': serializer.errors},
                status=status.HTTP_400_BAD_REQUEST,
            )
        room_id = request.data.get('room_id') or 'soul_sync_room_default'
        queue = QueueService.get_or_create_queue(room_id, request.user)
        updated_queue = QueueService.play_next(queue, serializer.validated_data, request.user)
        return Response(
            {
                'success': True,
                'message': 'Song added to Play Next in shared queue.',
                'data': SharedQueueSerializer(updated_queue).data,
            },
            status=status.HTTP_200_OK,
        )


class ReorderQueueView(APIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(request=ReorderQueueSerializer, responses={200: SharedQueueSerializer})
    def post(self, request):
        serializer = ReorderQueueSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(
                {'success': False, 'errors': serializer.errors},
                status=status.HTTP_400_BAD_REQUEST,
            )
        room_id = request.data.get('room_id') or 'soul_sync_room_default'
        queue = QueueService.get_or_create_queue(room_id, request.user)
        updated_queue = QueueService.reorder_queue(
            queue,
            serializer.validated_data['old_index'],
            serializer.validated_data['new_index'],
            request.user,
        )
        return Response(
            {
                'success': True,
                'message': 'Shared queue reordered.',
                'data': SharedQueueSerializer(updated_queue).data,
            },
            status=status.HTTP_200_OK,
        )


class RemoveSongView(APIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(request=RemoveSongSerializer, responses={200: SharedQueueSerializer})
    def post(self, request):
        serializer = RemoveSongSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(
                {'success': False, 'errors': serializer.errors},
                status=status.HTTP_400_BAD_REQUEST,
            )
        room_id = request.data.get('room_id') or 'soul_sync_room_default'
        queue = QueueService.get_or_create_queue(room_id, request.user)
        updated_queue = QueueService.remove_song(
            queue,
            serializer.validated_data['index'],
            request.user,
        )
        return Response(
            {
                'success': True,
                'message': 'Song removed from shared queue.',
                'data': SharedQueueSerializer(updated_queue).data,
            },
            status=status.HTTP_200_OK,
        )


class ClearQueueView(APIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(responses={200: SharedQueueSerializer})
    def post(self, request):
        room_id = request.data.get('room_id') or 'soul_sync_room_default'
        queue = QueueService.get_or_create_queue(room_id, request.user)
        updated_queue = QueueService.clear_queue(queue, request.user)
        return Response(
            {
                'success': True,
                'message': 'Shared queue cleared.',
                'data': SharedQueueSerializer(updated_queue).data,
            },
            status=status.HTTP_200_OK,
        )


class SyncQueueView(APIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(responses={200: SharedQueueSerializer})
    def post(self, request):
        room_id = request.data.get('room_id') or 'soul_sync_room_default'
        queue = QueueService.get_or_create_queue(room_id, request.user)
        QueueService.broadcast_queue_event(queue, 'queue_synced')
        return Response(
            {
                'success': True,
                'message': 'Shared queue sync snapshot triggered.',
                'data': SharedQueueSerializer(queue).data,
            },
            status=status.HTTP_200_OK,
        )


class SelectSongView(APIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(responses={200: SharedQueueSerializer})
    def post(self, request):
        room_id = request.data.get('room_id') or 'soul_sync_room_default'
        index = request.data.get('index')
        if index is None or not isinstance(index, int):
            return Response(
                {'success': False, 'message': 'Valid index parameter is required.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        queue = QueueService.get_or_create_queue(room_id, request.user)
        updated_queue = QueueService.set_current_index(queue, index, request.user)
        return Response(
            {
                'success': True,
                'message': 'Selected song index updated.',
                'data': SharedQueueSerializer(updated_queue).data,
            },
            status=status.HTTP_200_OK,
        )
