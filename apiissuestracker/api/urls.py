from django.urls import path, include
from api import views
from rest_framework import routers

router = routers.DefaultRouter()
router.register('projects', views.ProjectView, base_name='projects')
router.register('project', views.ProjectIssuesView, base_name='project')
router.register('issues', views.IssueView, base_name='issues')
router.register('comments', views.CommentView, base_name='comments')

urlpatterns = [
	path('', include(router.urls))
]
