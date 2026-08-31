from django.urls import path
from apps.core.views import HealthCheckView, MusicCatalogView

urlpatterns = [
    path('health/', HealthCheckView.as_view(), name='health_check'),
    path('music/', MusicCatalogView.as_view(), name='music_catalog'),
]

