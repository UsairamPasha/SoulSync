from django.test import TestCase
from django.urls import reverse
from rest_framework import status

class CoreHealthCheckTestCase(TestCase):
    def test_health_check_endpoint(self):
        url = reverse('health_check')
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data['success'])
        self.assertEqual(response.data['data']['status'], 'healthy')
