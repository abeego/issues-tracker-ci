from django.test import TestCase
from api.models import Project

class ModelTestCase(TestCase):
    """
    This test case defines the test suite for project model.
    """

    def setUp(self):
        """
        Defining test client and other test variables
        """
        self.project_name = "New Project 1"
        self.project_description = "Awesome Project"
        self.project = Project(name=self.project_name, description=self.project_description)

    def test_model_can_create_project(self):
        """
        Test the project model can create a project
        """
        old_count = Project.objects.count()
        self.project.save()
        new_count = Project.objects.count()
        self.assertNotEqual(old_count, new_count)
