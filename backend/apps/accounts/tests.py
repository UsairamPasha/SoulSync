from django.test import TestCase
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APIClient
from apps.accounts.models import CustomUser

class AccountsAuthTestCase(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.email = 'testuser@soulsync.app'
        self.password = 'SoulSyncPass123!'
        self.register_url = reverse('auth_register')
        self.login_url = reverse('auth_login')
        self.me_url = reverse('auth_me')

    def test_register_user_success(self):
        payload = {
            'email': self.email,
            'password': self.password,
            'password_confirm': self.password,
            'display_name': 'Test Partner',
        }
        response = self.client.post(self.register_url, payload, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertTrue(response.data['success'])
        self.assertIn('accessToken', response.data['data'])
        self.assertIn('refreshToken', response.data['data'])

    def test_login_user_success(self):
        user = CustomUser.objects.create_user(email=self.email, password=self.password)
        payload = {
            'email': self.email,
            'password': self.password,
        }
        response = self.client.post(self.login_url, payload, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data['success'])
        self.assertIn('accessToken', response.data['data'])

    def test_user_me_endpoint_requires_auth(self):
        response = self.client.get(self.me_url)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        self.assertFalse(response.data['success'])
