from rest_framework import serializers
from api.models import Project, Issue, Comment
from django.contrib.auth.models import User

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('username', 'email', 'password',)

class UserInfoSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('username',)

class CommentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Comment
        fields = ('id', 'issue', 'body', 'created_at',)

class IssueSerializer(serializers.ModelSerializer):
    comments = CommentSerializer(many=True, read_only=True)
    url = serializers.HyperlinkedIdentityField(
        view_name="issues-detail",
    )
    class Meta:
        model = Issue
        fields = ('id', 'project', 'url', 'name', 'description', 'status', 'created_at', 'comments',)

class ProjectSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = Project
        fields = ('id', 'name', 'description', 'created_at',)

class ProjectIssuesSerializers(serializers.ModelSerializer):
    issues = IssueSerializer(many=True, read_only=True)
    class Meta:
        model = Project
        fields = ('id', 'name', 'issues',)
