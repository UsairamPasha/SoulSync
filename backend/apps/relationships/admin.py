from django.contrib import admin
from apps.relationships.models import CoupleRelationship, CoupleInvitation

@admin.register(CoupleRelationship)
class CoupleRelationshipAdmin(admin.ModelAdmin):
    list_display = ('user_one', 'user_two', 'relationship_status', 'anniversary_date', 'created_at')
    list_filter = ('relationship_status',)
    search_fields = ('user_one__email', 'user_two__email')

@admin.register(CoupleInvitation)
class CoupleInvitationAdmin(admin.ModelAdmin):
    list_display = ('invitation_code', 'sender', 'receiver', 'status', 'expires_at', 'created_at')
    list_filter = ('status',)
    search_fields = ('invitation_code', 'sender__email', 'receiver__email')
