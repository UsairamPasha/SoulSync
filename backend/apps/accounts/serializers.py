from rest_framework import serializers
from django.contrib.auth import authenticate
from apps.accounts.models import CustomUser

class UserSerializer(serializers.ModelSerializer):
    displayName = serializers.CharField(source='display_name', read_only=False, required=False)
    avatarUrl = serializers.SerializerMethodField()

    class Meta:
        model = CustomUser
        fields = (
            'id',
            'email',
            'first_name',
            'last_name',
            'display_name',
            'displayName',
            'avatarUrl',
            'bio',
            'favorite_genre',
            'favorite_artist',
            'listening_goal',
            'timezone',
            'country',
            'is_verified',
            'is_online',
            'last_seen',
            'date_joined',
        )

    def get_avatarUrl(self, obj):
        if obj.avatar:
            request = self.context.get('request')
            if request:
                return request.build_absolute_uri(obj.avatar.url)
            return obj.avatar.url
        if obj.profile_picture:
            request = self.context.get('request')
            if request:
                return request.build_absolute_uri(obj.profile_picture.url)
            return obj.profile_picture.url
        return f"https://api.dicebear.com/7.x/avataaars/svg?seed={obj.email}"

class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=8)
    password_confirm = serializers.CharField(write_only=True, min_length=8)

    class Meta:
        model = CustomUser
        fields = ('email', 'password', 'password_confirm', 'first_name', 'last_name', 'display_name')

    def validate(self, attrs):
        if attrs['password'] != attrs['password_confirm']:
            raise serializers.ValidationError({'password': 'Passwords do not match.'})
        return attrs

    def create(self, validated_data):
        validated_data.pop('password_confirm')
        email = validated_data['email'].lower().strip()
        user = CustomUser.objects.create_user(
            email=email,
            password=validated_data['password'],
            first_name=validated_data.get('first_name', ''),
            last_name=validated_data.get('last_name', ''),
            display_name=validated_data.get('display_name', ''),
        )
        return user

class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)

    def validate(self, attrs):
        email = attrs.get('email', '').strip()
        password = attrs.get('password', '')

        if email and password:
            user = authenticate(request=self.context.get('request'), username=email.lower(), password=password)
            if not user:
                user_obj = CustomUser.objects.filter(email__iexact=email).first()
                if user_obj and user_obj.check_password(password):
                    user = user_obj
            if not user:
                raise serializers.ValidationError('Invalid email or password.')
            if not user.is_active:
                raise serializers.ValidationError('User account is disabled.')
        else:
            raise serializers.ValidationError('Must include email and password.')

        attrs['user'] = user
        return attrs

class UserProfileUpdateSerializer(serializers.ModelSerializer):
    displayName = serializers.CharField(source='display_name', required=False, allow_blank=True)

    class Meta:
        model = CustomUser
        fields = (
            'first_name',
            'last_name',
            'display_name',
            'displayName',
            'bio',
            'favorite_genre',
            'favorite_artist',
            'listening_goal',
            'timezone',
            'country',
        )

class AvatarUploadSerializer(serializers.Serializer):
    avatar = serializers.ImageField()
