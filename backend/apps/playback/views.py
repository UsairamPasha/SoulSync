from rest_framework import permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from drf_spectacular.utils import extend_schema
from apps.playback.serializers import PlaybackSessionSerializer, PlaybackActionSerializer
from apps.playback.services import PlaybackService

class StartPlaybackSessionView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(responses={200: PlaybackSessionSerializer})
    def post(self, request):
        user = request.user
        room_id = request.data.get('roomId', 'soul_sync_room_default')
        try:
            session = PlaybackService.start_session(user, room_id=room_id)
            return Response(
                {
                    'success': True,
                    'message': 'Playback session started successfully.',
                    'data': PlaybackSessionSerializer(session).data,
                },
                status=status.HTTP_200_OK,
            )
        except PermissionError as pe:
            return Response(
                {
                    'success': False,
                    'message': str(pe),
                    'errors': None,
                },
                status=status.HTTP_403_FORBIDDEN,
            )
        except Exception as e:
            return Response(
                {
                    'success': False,
                    'message': f'Failed to start playback session: {e}',
                    'errors': None,
                },
                status=status.HTTP_400_BAD_REQUEST,
            )

class CurrentPlaybackSessionView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(responses={200: PlaybackSessionSerializer})
    def get(self, request):
        user = request.user
        session = PlaybackService.get_active_session(user)
        if not session:
            return Response(
                {
                    'success': True,
                    'message': 'No active playback session.',
                    'data': None,
                },
                status=status.HTTP_200_OK,
            )
        return Response(
            {
                'success': True,
                'message': 'Active playback session retrieved.',
                'data': PlaybackSessionSerializer(session).data,
            },
            status=status.HTTP_200_OK,
        )

class PlaySessionView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(request=PlaybackActionSerializer, responses={200: PlaybackSessionSerializer})
    def post(self, request):
        user = request.user
        serializer = PlaybackActionSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        position_ms = serializer.validated_data.get('position_ms', 0)
        song_id = serializer.validated_data.get('song_id')

        try:
            session = PlaybackService.play(user, position_ms=position_ms, song_id=song_id)
            return Response(
                {
                    'success': True,
                    'message': 'Playback playing.',
                    'data': PlaybackSessionSerializer(session).data,
                },
                status=status.HTTP_200_OK,
            )
        except PermissionError as pe:
            return Response(
                {
                    'success': False,
                    'message': str(pe),
                    'errors': None,
                },
                status=status.HTTP_403_FORBIDDEN,
            )
        except Exception as e:
            return Response(
                {
                    'success': False,
                    'message': str(e),
                    'errors': None,
                },
                status=status.HTTP_400_BAD_REQUEST,
            )

class PauseSessionView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(request=PlaybackActionSerializer, responses={200: PlaybackSessionSerializer})
    def post(self, request):
        user = request.user
        serializer = PlaybackActionSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        position_ms = serializer.validated_data.get('position_ms', 0)

        try:
            session = PlaybackService.pause(user, position_ms=position_ms)
            return Response(
                {
                    'success': True,
                    'message': 'Playback paused.',
                    'data': PlaybackSessionSerializer(session).data,
                },
                status=status.HTTP_200_OK,
            )
        except PermissionError as pe:
            return Response(
                {
                    'success': False,
                    'message': str(pe),
                    'errors': None,
                },
                status=status.HTTP_403_FORBIDDEN,
            )
        except Exception as e:
            return Response(
                {
                    'success': False,
                    'message': str(e),
                    'errors': None,
                },
                status=status.HTTP_400_BAD_REQUEST,
            )

class ResumeSessionView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(request=PlaybackActionSerializer, responses={200: PlaybackSessionSerializer})
    def post(self, request):
        user = request.user
        serializer = PlaybackActionSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        position_ms = serializer.validated_data.get('position_ms', 0)

        try:
            session = PlaybackService.resume(user, position_ms=position_ms)
            return Response(
                {
                    'success': True,
                    'message': 'Playback resumed.',
                    'data': PlaybackSessionSerializer(session).data,
                },
                status=status.HTTP_200_OK,
            )
        except PermissionError as pe:
            return Response(
                {
                    'success': False,
                    'message': str(pe),
                    'errors': None,
                },
                status=status.HTTP_403_FORBIDDEN,
            )
        except Exception as e:
            return Response(
                {
                    'success': False,
                    'message': str(e),
                    'errors': None,
                },
                status=status.HTTP_400_BAD_REQUEST,
            )

class SeekSessionView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(request=PlaybackActionSerializer, responses={200: PlaybackSessionSerializer})
    def post(self, request):
        user = request.user
        serializer = PlaybackActionSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        position_ms = serializer.validated_data.get('position_ms', 0)
        song_id = serializer.validated_data.get('song_id')

        try:
            session = PlaybackService.seek(user, position_ms=position_ms, song_id=song_id)
            return Response(
                {
                    'success': True,
                    'message': 'Playback seek updated.',
                    'data': PlaybackSessionSerializer(session).data,
                },
                status=status.HTTP_200_OK,
            )
        except Exception as e:
            return Response(
                {
                    'success': False,
                    'message': str(e),
                    'errors': None,
                },
                status=status.HTTP_400_BAD_REQUEST,
            )

class PlaybackStateView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(responses={200: PlaybackSessionSerializer})
    def post(self, request):
        user = request.user
        position_ms = request.data.get('position_ms', 0)
        playing = request.data.get('playing', True)
        queue_index = request.data.get('queue_index', 0)
        song_id = request.data.get('song_id')

        try:
            session = PlaybackService.heartbeat(
                user,
                position_ms=position_ms,
                playing=playing,
                queue_index=queue_index,
                song_id=song_id,
            )
            return Response(
                {
                    'success': True,
                    'message': 'Playback state updated.',
                    'data': PlaybackSessionSerializer(session).data if session else None,
                },
                status=status.HTTP_200_OK,
            )
        except Exception as e:
            return Response(
                {
                    'success': False,
                    'message': str(e),
                    'errors': None,
                },
                status=status.HTTP_400_BAD_REQUEST,
            )

class EndPlaybackSessionView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(responses={200: PlaybackSessionSerializer})
    def post(self, request):
        user = request.user
        try:
            session = PlaybackService.end_session(user)
            return Response(
                {
                    'success': True,
                    'message': 'Playback session ended.',
                    'data': PlaybackSessionSerializer(session).data if session else None,
                },
                status=status.HTTP_200_OK,
            )
        except PermissionError as pe:
            return Response(
                {
                    'success': False,
                    'message': str(pe),
                    'errors': None,
                },
                status=status.HTTP_403_FORBIDDEN,
            )
        except Exception as e:
            return Response(
                {
                    'success': False,
                    'message': str(e),
                    'errors': None,
                },
                status=status.HTTP_400_BAD_REQUEST,
            )
