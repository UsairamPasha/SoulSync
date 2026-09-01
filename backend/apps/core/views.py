import os
import re
from pathlib import Path
from urllib.parse import quote, unquote
from django.conf import settings
from django.db import connection
from django.http import HttpResponse, StreamingHttpResponse, FileResponse
from django.utils import timezone
from django.views import View
from rest_framework import permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from decouple import config

class HealthCheckView(APIView):
    permission_classes = [permissions.AllowAny]

    def get(self, request):
        db_status = 'healthy'
        try:
            with connection.cursor() as cursor:
                cursor.execute("SELECT 1")
        except Exception as e:
            db_status = f'unhealthy ({e})'

        return Response(
            {
                'success': True,
                'message': 'System health check status.',
                'data': {
                    'status': 'healthy' if db_status == 'healthy' else 'degraded',
                    'database': db_status,
                    'version': '1.0.0',
                    'environment': config('ENVIRONMENT', default='development'),
                    'timestamp': timezone.now().isoformat(),
                },
            },
            status=status.HTTP_200_OK if db_status == 'healthy' else status.HTTP_503_SERVICE_UNAVAILABLE,
        )

class MusicCatalogView(APIView):
    permission_classes = [permissions.AllowAny]

    def get(self, request):
        music_dir = Path(settings.MEDIA_ROOT) / 'music'
        tracks = []
        if music_dir.exists():
            files = sorted([f for f in os.listdir(music_dir) if f.lower().endswith('.mp3')])
            index = 1
            for filename in files:
                name_without_ext = filename[:-4]
                if filename == 'sample_1.mp3':
                    song_id = 'song_1'
                    title = 'Sample 1'
                    artist = 'SoulSync Audio'
                elif filename == 'sample_2.mp3':
                    song_id = 'song_2'
                    title = 'Sample 2'
                    artist = 'SoulSync Audio'
                elif filename == 'sample_3.mp3':
                    song_id = 'song_3'
                    title = 'Sample 3'
                    artist = 'SoulSync Audio'
                else:
                    song_id = f'remote_music_{index}'
                    parts = name_without_ext.split(' - ')
                    if len(parts) >= 2:
                        artist = parts[0].strip()
                        title = ' - '.join(parts[1:]).strip()
                    else:
                        title = name_without_ext.strip()
                        artist = 'SoulSync Cloud Library'

                encoded_filename = quote(filename)
                stream_url = request.build_absolute_uri(f"{settings.MEDIA_URL}music/{encoded_filename}")
                if stream_url.startswith('http://'):
                    stream_url = stream_url.replace('http://', 'https://', 1)
                tracks.append({
                    'id': song_id,
                    'title': title,
                    'artist': artist,
                    'album': 'SoulSync Cloud Library',
                    'asset_path': stream_url,
                    'stream_url': stream_url,
                    'duration_ms': 210000,
                })
                index += 1

        return Response({
            'success': True,
            'count': len(tracks),
            'data': tracks,
        })

class RangeFileWrapper:
    def __init__(self, file_obj, offset=0, length=None, blksize=131072):
        self.file_obj = file_obj
        self.file_obj.seek(offset)
        self.remaining = length
        self.blksize = blksize

    def __iter__(self):
        return self

    def __next__(self):
        try:
            if self.remaining is not None and self.remaining <= 0:
                self.file_obj.close()
                raise StopIteration
            read_len = self.blksize if self.remaining is None else min(self.remaining, self.blksize)
            data = self.file_obj.read(read_len)
            if not data:
                self.file_obj.close()
                raise StopIteration
            if self.remaining is not None:
                self.remaining -= len(data)
            return data
        except (BrokenPipeError, ConnectionResetError, OSError):
            try:
                self.file_obj.close()
            except Exception:
                pass
            raise StopIteration

class StreamAudioView(View):
    def get(self, request, filename):
        decoded = unquote(filename)
        while '%' in decoded:
            new_decoded = unquote(decoded)
            if new_decoded == decoded:
                break
            decoded = new_decoded

        file_path = Path(settings.MEDIA_ROOT) / 'music' / decoded
        if not file_path.exists():
            file_path = Path(settings.MEDIA_ROOT) / 'music' / unquote(filename)
            if not file_path.exists():
                file_path = Path(settings.MEDIA_ROOT) / 'music' / filename
                if not file_path.exists():
                    return HttpResponse("File not found", status=404)

        file_size = file_path.stat().st_size
        range_header = request.META.get('HTTP_RANGE', '').strip()
        etag = f'"{filename}-{file_size}"'

        if range_header.startswith('bytes='):
            try:
                byte_positions = range_header.replace('bytes=', '').split('-')
                start_byte = int(byte_positions[0]) if byte_positions[0] else 0
                end_byte = int(byte_positions[1]) if len(byte_positions) > 1 and byte_positions[1] else file_size - 1

                if start_byte >= file_size:
                    return HttpResponse(status=416)

                end_byte = min(end_byte, file_size - 1)
                length = end_byte - start_byte + 1

                f = open(file_path, 'rb')
                wrapper = RangeFileWrapper(f, offset=start_byte, length=length)

                response = StreamingHttpResponse(
                    wrapper,
                    status=206,
                    content_type='audio/mpeg'
                )
                response['Content-Range'] = f'bytes {start_byte}-{end_byte}/{file_size}'
                response['Content-Length'] = str(length)
                response['Accept-Ranges'] = 'bytes'
                response['Cache-Control'] = 'public, max-age=31536000, immutable'
                response['ETag'] = etag
                response['Access-Control-Allow-Origin'] = '*'
                response['Access-Control-Allow-Methods'] = 'GET, OPTIONS'
                response['Access-Control-Allow-Headers'] = '*'
                response['Access-Control-Expose-Headers'] = 'Content-Range, Content-Length, Accept-Ranges'
                return response
            except Exception as e:
                pass

        response = FileResponse(
            open(file_path, 'rb'),
            status=200,
            content_type='audio/mpeg'
        )
        response['Content-Length'] = str(file_size)
        response['Accept-Ranges'] = 'bytes'
        response['Cache-Control'] = 'public, max-age=31536000, immutable'
        response['ETag'] = etag
        response['Access-Control-Allow-Origin'] = '*'
        response['Access-Control-Allow-Methods'] = 'GET, OPTIONS'
        response['Access-Control-Allow-Headers'] = '*'
        response['Access-Control-Expose-Headers'] = 'Content-Range, Content-Length, Accept-Ranges'
        return response

    def options(self, request, filename):
        response = HttpResponse(status=200)
        response['Access-Control-Allow-Origin'] = '*'
        response['Access-Control-Allow-Methods'] = 'GET, OPTIONS'
        response['Access-Control-Allow-Headers'] = '*'
        response['Access-Control-Expose-Headers'] = 'Content-Range, Content-Length, Accept-Ranges'
        return response
