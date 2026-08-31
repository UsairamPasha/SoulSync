from rest_framework import status, permissions
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.views import TokenRefreshView
from drf_spectacular.utils import extend_schema

from apps.accounts.serializers import (
    RegisterSerializer,
    LoginSerializer,
    UserSerializer,
    UserProfileUpdateSerializer,
    AvatarUploadSerializer,
)

class RegisterView(APIView):
    permission_classes = [permissions.AllowAny]

    @extend_schema(request=RegisterSerializer, responses={201: UserSerializer})
    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            refresh = RefreshToken.for_user(user)

            return Response(
                {
                    'success': True,
                    'message': 'User registered successfully.',
                    'data': {
                        'user': UserSerializer(user, context={'request': request}).data,
                        'accessToken': str(refresh.access_token),
                        'refreshToken': str(refresh),
                    },
                },
                status=status.HTTP_201_CREATED,
            )
        return Response(
            {
                'success': False,
                'message': 'Registration validation failed.',
                'errors': serializer.errors,
            },
            status=status.HTTP_400_BAD_REQUEST,
        )

class LoginView(APIView):
    permission_classes = [permissions.AllowAny]

    @extend_schema(request=LoginSerializer, responses={200: UserSerializer})
    def post(self, request):
        serializer = LoginSerializer(data=request.data, context={'request': request})
        if serializer.is_valid():
            user = serializer.validated_data['user']
            refresh = RefreshToken.for_user(user)

            return Response(
                {
                    'success': True,
                    'message': 'Login successful.',
                    'data': {
                        'user': UserSerializer(user, context={'request': request}).data,
                        'accessToken': str(refresh.access_token),
                        'refreshToken': str(refresh),
                    },
                },
                status=status.HTTP_200_OK,
            )
        return Response(
            {
                'success': False,
                'message': 'Invalid login credentials.',
                'errors': serializer.errors,
            },
            status=status.HTTP_400_BAD_REQUEST,
        )

class LogoutView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        try:
            refresh_token = request.data.get('refreshToken')
            if refresh_token:
                token = RefreshToken(refresh_token)
                token.blacklist()
        except Exception:
            pass

        return Response(
            {
                'success': True,
                'message': 'Logged out successfully.',
                'data': None,
            },
            status=status.HTTP_200_OK,
        )

class CustomTokenRefreshView(TokenRefreshView):
    def post(self, request, *args, **kwargs):
        response = super().post(request, *args, **kwargs)
        if response.status_code == 200:
            data = response.data
            return Response(
                {
                    'success': True,
                    'message': 'Token refreshed successfully.',
                    'data': {
                        'accessToken': data.get('access'),
                        'refreshToken': data.get('refresh', request.data.get('refreshToken')),
                    },
                },
                status=status.HTTP_200_OK,
            )
        return response

class UserProfileView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(responses={200: UserSerializer})
    def get(self, request):
        serializer = UserSerializer(request.user, context={'request': request})
        return Response(
            {
                'success': True,
                'message': 'Profile retrieved successfully.',
                'data': serializer.data,
            },
            status=status.HTTP_200_OK,
        )

    @extend_schema(request=UserProfileUpdateSerializer, responses={200: UserSerializer})
    def patch(self, request):
        serializer = UserProfileUpdateSerializer(request.user, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(
                {
                    'success': True,
                    'message': 'Profile updated successfully.',
                    'data': UserSerializer(request.user, context={'request': request}).data,
                },
                status=status.HTTP_200_OK,
            )
        return Response(
            {
                'success': False,
                'message': 'Profile update validation failed.',
                'errors': serializer.errors,
            },
            status=status.HTTP_400_BAD_REQUEST,
        )

class AvatarUploadView(APIView):
    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]

    @extend_schema(request=AvatarUploadSerializer, responses={200: UserSerializer})
    def post(self, request):
        serializer = AvatarUploadSerializer(data=request.data)
        if serializer.is_valid():
            request.user.avatar = serializer.validated_data['avatar']
            request.user.save()
            return Response(
                {
                    'success': True,
                    'message': 'Avatar uploaded successfully.',
                    'data': UserSerializer(request.user, context={'request': request}).data,
                },
                status=status.HTTP_200_OK,
            )
        return Response(
            {
                'success': False,
                'message': 'Avatar upload validation failed.',
                'errors': serializer.errors,
            },
            status=status.HTTP_400_BAD_REQUEST,
        )
