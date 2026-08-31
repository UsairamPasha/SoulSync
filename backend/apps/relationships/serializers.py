from rest_framework import serializers
from apps.accounts.serializers import UserSerializer
from apps.relationships.models import CoupleRelationship, CoupleInvitation

class CoupleInvitationSerializer(serializers.ModelSerializer):
    sender = UserSerializer(read_only=True)
    receiver = UserSerializer(read_only=True)

    class Meta:
        model = CoupleInvitation
        fields = (
            'id',
            'sender',
            'receiver',
            'invitation_code',
            'status',
            'expires_at',
            'created_at',
        )

class CoupleRelationshipSerializer(serializers.ModelSerializer):
    user_one = UserSerializer(read_only=True)
    user_two = UserSerializer(read_only=True)
    partner = serializers.SerializerMethodField()

    class Meta:
        model = CoupleRelationship
        fields = (
            'id',
            'user_one',
            'user_two',
            'partner',
            'relationship_status',
            'anniversary_date',
            'created_at',
        )

    def get_partner(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            partner = obj.get_partner(request.user)
            return UserSerializer(partner, context=self.context).data
        return None

class AcceptInviteSerializer(serializers.Serializer):
    code = serializers.CharField(max_length=20)

class RejectInviteSerializer(serializers.Serializer):
    code = serializers.CharField(max_length=20)
