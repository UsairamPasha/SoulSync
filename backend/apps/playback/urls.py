from django.urls import path
from apps.playback.views import (
    StartPlaybackSessionView,
    CurrentPlaybackSessionView,
    PlaySessionView,
    PauseSessionView,
    ResumeSessionView,
    SeekSessionView,
    PlaybackStateView,
    EndPlaybackSessionView,
)

urlpatterns = [
    path('session/start/', StartPlaybackSessionView.as_view(), name='playback_session_start'),
    path('session/current/', CurrentPlaybackSessionView.as_view(), name='playback_session_current'),
    path('session/play/', PlaySessionView.as_view(), name='playback_session_play'),
    path('session/pause/', PauseSessionView.as_view(), name='playback_session_pause'),
    path('session/resume/', ResumeSessionView.as_view(), name='playback_session_resume'),
    path('session/seek/', SeekSessionView.as_view(), name='playback_session_seek'),
    path('session/state/', PlaybackStateView.as_view(), name='playback_session_state'),
    path('session/end/', EndPlaybackSessionView.as_view(), name='playback_session_end'),
]
