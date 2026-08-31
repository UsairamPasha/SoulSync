from django.test import TestCase
from rest_framework.test import APIClient
from rest_framework import status
from apps.accounts.models import CustomUser
from apps.relationships.models import CoupleRelationship, CoupleInvitation, RelationshipStatus

class RelationshipAPITestCase(TestCase):
    def setUp(self):
        self.user1 = CustomUser.objects.create_user(
            email='alice@soulsync.app',
            password='Password123!',
            first_name='Alice',
            display_name='Alice',
        )
        self.user2 = CustomUser.objects.create_user(
            email='bob@soulsync.app',
            password='Password123!',
            first_name='Bob',
            display_name='Bob',
        )

        self.client1 = APIClient()
        self.client1.force_authenticate(user=self.user1)

        self.client2 = APIClient()
        self.client2.force_authenticate(user=self.user2)

    def test_invite_and_accept_workflow(self):
        # 1. Create Invite
        res1 = self.client1.post('/api/v1/relationship/invite/')
        self.assertEqual(res1.status_code, status.HTTP_201_CREATED)
        code = res1.data['data']['invitation_code']
        self.assertTrue(code.startswith('SOUL-'))

        # 2. Accept Invite
        res2 = self.client2.post('/api/v1/relationship/accept/', {'code': code})
        self.assertEqual(res2.status_code, status.HTTP_200_OK)
        self.assertTrue(res2.data['success'])

        # 3. Check Relationship Detail
        res3 = self.client1.get('/api/v1/relationship/')
        self.assertEqual(res3.status_code, status.HTTP_200_OK)
        self.assertTrue(res3.data['data']['hasRelationship'])

        # 4. Check Partner Profile
        res4 = self.client1.get('/api/v1/relationship/partner/')
        self.assertEqual(res4.status_code, status.HTTP_200_OK)
        self.assertEqual(res4.data['data']['email'], 'bob@soulsync.app')

        # 5. Delete Relationship
        res5 = self.client1.delete('/api/v1/relationship/')
        self.assertEqual(res5.status_code, status.HTTP_200_OK)
        self.assertFalse(CoupleRelationship.objects.exists())
