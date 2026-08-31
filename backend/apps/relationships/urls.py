from django.urls import path
from apps.relationships.views import (
    CreateInviteView,
    AcceptInviteView,
    RejectInviteView,
    RelationshipDetailView,
    PartnerProfileView,
)

urlpatterns = [
    path('invite/', CreateInviteView.as_view(), name='relationship_invite'),
    path('accept/', AcceptInviteView.as_view(), name='relationship_accept'),
    path('reject/', RejectInviteView.as_view(), name='relationship_reject'),
    path('partner/', PartnerProfileView.as_view(), name='relationship_partner'),
    path('', RelationshipDetailView.as_view(), name='relationship_detail'),
]
