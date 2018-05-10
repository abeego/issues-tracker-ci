from django.test import TestCase
from rest_framework.test import APIClient
from rest_framework import status
from django.urls import reverse

class ProjectViewTestCase(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.project_data = {"name": "Awesome project 2", "description": "Great one again"}
        self.response = self.client.post(
            reverse('projects-list'),
            self.project_data,
            format='json'
        )

    def test_api_can_not_unauthorized_create_a_project(self):
        self.assertEqual(self.response.status_code, status.HTTP_401_UNAUTHORIZED)
