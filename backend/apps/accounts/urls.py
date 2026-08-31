from django.urls import path
from apps.accounts.views import (
    RegisterView,
    LoginView,
    LogoutView,
    CustomTokenRefreshView,
    UserProfileView,
    AvatarUploadView,
)

urlpatterns = [
    path('register/', RegisterView.as_view(), name='auth_register'),
    path('login/', LoginView.as_view(), name='auth_login'),
    path('logout/', LogoutView.as_view(), name='auth_logout'),
    path('token/refresh/', CustomTokenRefreshView.as_view(), name='auth_token_refresh'),
    path('me/', UserProfileView.as_view(), name='auth_me'),
    path('profile/', UserProfileView.as_view(), name='auth_profile'),
    path('profile/avatar/', AvatarUploadView.as_view(), name='auth_avatar'),
]
