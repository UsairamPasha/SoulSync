from django.conf import settings
from django.conf.urls.static import static
from django.contrib import admin
from django.urls import include, path
from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView
from apps.accounts.views import UserProfileView, AvatarUploadView

from apps.core.views import StreamAudioView

urlpatterns = [
    path('admin/', admin.site.urls),

    # High-Performance HTTP 206 Range Request Music Streaming
    path('media/music/<str:filename>', StreamAudioView.as_view(), name='stream_music'),

    # API v1 Versioned Endpoints
    path('api/v1/auth/', include('apps.accounts.urls')),
    path('api/v1/profile/', UserProfileView.as_view(), name='api_profile'),
    path('api/v1/profile/avatar/', AvatarUploadView.as_view(), name='api_avatar'),
    path('api/v1/relationship/', include('apps.relationships.urls')),
    path('api/v1/playback/', include('apps.playback.urls')),
    path('api/v1/queue/', include('apps.queue.urls')),
    path('api/v1/', include('apps.core.urls')),

    # OpenAPI 3 / Swagger Documentation
    path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
    path('api/docs/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'),
]

urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)

