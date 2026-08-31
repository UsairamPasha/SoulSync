from rest_framework import status, permissions
from rest_framework.views import APIView
from rest_framework.response import Response
from drf_spectacular.utils import extend_schema
from channels.layers import get_channel_layer
from asgiref.sync import async_to_sync

from apps.accounts.serializers import UserSerializer
from apps.relationships.models import (
    CoupleRelationship,
    CoupleInvitation,
    RelationshipStatus,
    InvitationStatus,
    generate_invitation_code,
)
from apps.relationships.serializers import (
    CoupleInvitationSerializer,
    CoupleRelationshipSerializer,
    AcceptInviteSerializer,
    RejectInviteSerializer,
)

class CreateInviteView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(responses={201: CoupleInvitationSerializer})
    def post(self, request):
        user = request.user
        existing_rel = CoupleRelationship.get_user_relationship(user)
        if existing_rel:
            return Response(
                {
                    'success': False,
                    'message': 'You are already in a couple relationship.',
                    'errors': None,
                },
                status=status.HTTP_400_BAD_REQUEST,
            )

        # Cancel previous pending invitations from this user
        CoupleInvitation.objects.filter(sender=user, status=InvitationStatus.PENDING).update(
            status=InvitationStatus.EXPIRED
        )

        code = generate_invitation_code()
        invitation = CoupleInvitation.objects.create(
            sender=user,
            invitation_code=code,
        )

        return Response(
            {
                'success': True,
                'message': 'Invitation code generated successfully.',
                'data': CoupleInvitationSerializer(invitation, context={'request': request}).data,
            },
            status=status.HTTP_201_CREATED,
        )

class AcceptInviteView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(request=AcceptInviteSerializer, responses={200: CoupleRelationshipSerializer})
    def post(self, request):
        serializer = AcceptInviteSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(
                {
                    'success': False,
                    'message': 'Invalid invitation code payload.',
                    'errors': serializer.errors,
                },
                status=status.HTTP_400_BAD_REQUEST,
            )

        code = serializer.validated_data['code'].strip().upper()
        user = request.user

        existing_rel = CoupleRelationship.get_user_relationship(user)
        if existing_rel:
            return Response(
                {
                    'success': False,
                    'message': 'You are already in a couple relationship.',
                    'errors': None,
                },
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            invitation = CoupleInvitation.objects.get(invitation_code=code)
        except CoupleInvitation.DoesNotExist:
            return Response(
                {
                    'success': False,
                    'message': 'Invalid invitation code.',
                    'errors': None,
                },
                status=status.HTTP_404_NOT_FOUND,
            )

        if not invitation.is_valid():
            return Response(
                {
                    'success': False,
                    'message': 'This invitation code is expired or invalid.',
                    'errors': None,
                },
                status=status.HTTP_400_BAD_REQUEST,
            )

        if invitation.sender == user:
            return Response(
                {
                    'success': False,
                    'message': 'You cannot accept your own invitation code.',
                    'errors': None,
                },
                status=status.HTTP_400_BAD_REQUEST,
            )

        invitation.receiver = user
        invitation.status = InvitationStatus.ACCEPTED
        invitation.save()

        relationship = CoupleRelationship.objects.create(
            user_one=invitation.sender,
            user_two=user,
            relationship_status=RelationshipStatus.ACCEPTED,
        )

        # Broadcast two-way real-time presence and relationship updates over WebSockets
        try:
            channel_layer = get_channel_layer()
            if channel_layer:
                rel_event = {
                    'type': 'relationship_update',
                    'event': 'relationship_created',
                    'status': 'accepted',
                    'userId': str(user.id),
                }
                async_to_sync(channel_layer.group_send)(f"user_{invitation.sender.id}", rel_event)
                async_to_sync(channel_layer.group_send)(f"user_{user.id}", rel_event)

                async_to_sync(channel_layer.group_send)(
                    f"user_{invitation.sender.id}",
                    {
                        'type': 'presence_update',
                        'userId': str(user.id),
                        'isOnline': user.is_online,
                        'lastSeen': user.last_seen.isoformat() if user.last_seen else None,
                    },
                )
                async_to_sync(channel_layer.group_send)(
                    f"user_{user.id}",
                    {
                        'type': 'presence_update',
                        'userId': str(invitation.sender.id),
                        'isOnline': invitation.sender.is_online,
                        'lastSeen': invitation.sender.last_seen.isoformat() if invitation.sender.last_seen else None,
                    },
                )
        except Exception as e:
            pass

        return Response(
            {
                'success': True,
                'message': 'Couple relationship created successfully!',
                'data': CoupleRelationshipSerializer(relationship, context={'request': request}).data,
            },
            status=status.HTTP_200_OK,
        )

class RejectInviteView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(request=RejectInviteSerializer)
    def post(self, request):
        serializer = RejectInviteSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(
                {
                    'success': False,
                    'message': 'Invalid code payload.',
                    'errors': serializer.errors,
                },
                status=status.HTTP_400_BAD_REQUEST,
            )

        code = serializer.validated_data['code'].strip().upper()
        try:
            invitation = CoupleInvitation.objects.get(invitation_code=code)
            invitation.status = InvitationStatus.DECLINED
            invitation.receiver = request.user
            invitation.save()
        except CoupleInvitation.DoesNotExist:
            pass

        return Response(
            {
                'success': True,
                'message': 'Invitation declined.',
                'data': None,
            },
            status=status.HTTP_200_OK,
        )

class RelationshipDetailView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        user = request.user
        relationship = CoupleRelationship.get_user_relationship(user)
        pending_invitation = CoupleInvitation.objects.filter(
            sender=user, status=InvitationStatus.PENDING
        ).first()

        rel_data = (
            CoupleRelationshipSerializer(relationship, context={'request': request}).data
            if relationship
            else None
        )
        inv_data = (
            CoupleInvitationSerializer(pending_invitation, context={'request': request}).data
            if pending_invitation
            else None
        )

        return Response(
            {
                'success': True,
                'message': 'Relationship detail retrieved.',
                'data': {
                    'hasRelationship': relationship is not None,
                    'relationship': rel_data,
                    'pendingInvitation': inv_data,
                },
            },
            status=status.HTTP_200_OK,
        )

    def delete(self, request):
        user = request.user
        relationship = CoupleRelationship.get_user_relationship(user)
        if not relationship:
            return Response(
                {
                    'success': False,
                    'message': 'No active relationship found.',
                    'errors': None,
                },
                status=status.HTTP_404_NOT_FOUND,
            )

        partner = relationship.get_partner(user)
        relationship.delete()

        try:
            channel_layer = get_channel_layer()
            if channel_layer:
                rel_event = {
                    'type': 'relationship_update',
                    'event': 'relationship_removed',
                    'status': 'removed',
                    'userId': str(user.id),
                }
                if partner:
                    async_to_sync(channel_layer.group_send)(f"user_{partner.id}", rel_event)
                async_to_sync(channel_layer.group_send)(f"user_{user.id}", rel_event)
        except Exception:
            pass

        return Response(
            {
                'success': True,
                'message': 'Couple relationship ended successfully.',
                'data': None,
            },
            status=status.HTTP_200_OK,
        )

class PartnerProfileView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        user = request.user
        relationship = CoupleRelationship.get_user_relationship(user)
        if not relationship:
            return Response(
                {
                    'success': False,
                    'message': 'No partner found. You are not in a couple relationship.',
                    'errors': None,
                },
                status=status.HTTP_404_NOT_FOUND,
            )

        partner = relationship.get_partner(user)
        return Response(
            {
                'success': True,
                'message': 'Partner profile retrieved.',
                'data': UserSerializer(partner, context={'request': request}).data,
            },
            status=status.HTTP_200_OK,
        )
