import random
import string
from django.db import models
from django.utils import timezone
from apps.accounts.models import CustomUser
from apps.common.models import BaseModel

class RelationshipStatus(models.TextChoices):
    PENDING = 'pending', 'Pending'
    ACCEPTED = 'accepted', 'Accepted'
    REJECTED = 'rejected', 'Rejected'
    BLOCKED = 'blocked', 'Blocked'

class InvitationStatus(models.TextChoices):
    PENDING = 'pending', 'Pending'
    ACCEPTED = 'accepted', 'Accepted'
    DECLINED = 'declined', 'Declined'
    EXPIRED = 'expired', 'Expired'

def generate_invitation_code():
    digits = ''.join(random.choices(string.digits, k=4))
    return f"SOUL-{digits}"

class CoupleRelationship(BaseModel):
    user_one = models.ForeignKey(
        CustomUser,
        on_delete=models.CASCADE,
        related_name='relationships_as_user_one',
    )
    user_two = models.ForeignKey(
        CustomUser,
        on_delete=models.CASCADE,
        related_name='relationships_as_user_two',
    )
    relationship_status = models.CharField(
        max_length=20,
        choices=RelationshipStatus.choices,
        default=RelationshipStatus.ACCEPTED,
    )
    anniversary_date = models.DateField(null=True, blank=True)

    class Meta:
        verbose_name = 'Couple Relationship'
        verbose_name_plural = 'Couple Relationships'
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.user_one.email} ❤️ {self.user_two.email}"

    @classmethod
    def get_user_relationship(cls, user):
        return cls.objects.filter(
            models.Q(user_one=user) | models.Q(user_two=user),
            relationship_status=RelationshipStatus.ACCEPTED,
        ).first()

    def get_partner(self, user):
        if self.user_one == user:
            return self.user_two
        return self.user_one

class CoupleInvitation(BaseModel):
    sender = models.ForeignKey(
        CustomUser,
        on_delete=models.CASCADE,
        related_name='sent_invitations',
    )
    receiver = models.ForeignKey(
        CustomUser,
        on_delete=models.CASCADE,
        related_name='received_invitations',
        null=True,
        blank=True,
    )
    invitation_code = models.CharField(
        max_length=20,
        unique=True,
        db_index=True,
        default=generate_invitation_code,
    )
    status = models.CharField(
        max_length=20,
        choices=InvitationStatus.choices,
        default=InvitationStatus.PENDING,
    )
    expires_at = models.DateTimeField()

    class Meta:
        verbose_name = 'Couple Invitation'
        verbose_name_plural = 'Couple Invitations'
        ordering = ['-created_at']

    def save(self, *args, **kwargs):
        if not self.expires_at:
            self.expires_at = timezone.now() + timezone.timedelta(days=7)
        super().save(*args, **kwargs)

    def is_valid(self):
        return (
            self.status == InvitationStatus.PENDING
            and timezone.now() < self.expires_at
        )

    def __str__(self):
        return f"Invite {self.invitation_code} from {self.sender.email}"
