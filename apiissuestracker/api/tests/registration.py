from django.test import TestCase
from rest_framework.test import APIClient
from rest_framework import status
from django.urls import reverse


class RegisterViewTestCase(TestCase):
    """
    Test suite for the api views
    """

    def setUp(self):
        """
        Define the test client and other test variables
        """
        self.client = APIClient()
        self.user_data = {"username":"pamela","email":"pamela@example.com","password":"pamela123456"}
        self.response = self.client.post(
            reverse('user_registration'),
            self.user_data,
            format='json'
        )

    def test_api_can_create_a_user(self):
        """
        Test the api has project creation capability
        """
        self.assertEqual(self.response.status_code, status.HTTP_201_CREATED)
