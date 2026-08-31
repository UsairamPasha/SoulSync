from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from apps.accounts.models import CustomUser

@admin.register(CustomUser)
class CustomUserAdmin(UserAdmin):
    list_display = ('email', 'display_name', 'is_verified', 'is_online', 'is_staff', 'date_joined')
    list_filter = ('is_verified', 'is_online', 'is_staff', 'is_active')
    search_fields = ('email', 'display_name', 'first_name', 'last_name')
    ordering = ('-date_joined',)
    readonly_fields = ('last_seen', 'date_joined')

    fieldsets = (
        (None, {'fields': ('email', 'password')}),
        ('Personal Info', {'fields': ('first_name', 'last_name', 'display_name', 'profile_picture')}),
        ('Status', {'fields': ('is_verified', 'is_online', 'last_seen')}),
        ('Permissions', {'fields': ('is_active', 'is_staff', 'is_superuser', 'groups', 'user_permissions')}),
        ('Important Dates', {'fields': ('date_joined',)}),
    )

    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('email', 'password', 'display_name'),
        }),
    )
