from django.shortcuts import render
from rest_framework import viewsets, generics, permissions, status
from rest_framework.views import APIView
from rest_framework.response import Response
from api.models import Project, Issue, Comment
from django.contrib.auth.models import User
from api.serializers import (
    ProjectSerializer,
    ProjectIssuesSerializers,
    IssueSerializer,
    CommentSerializer,
    UserSerializer,
    UserInfoSerializer)

class ProjectView(viewsets.ModelViewSet):
    queryset = Project.objects.all()
    serializer_class = ProjectSerializer

class ProjectIssuesView(viewsets.ModelViewSet):
    queryset = Project.objects.all()
    serializer_class = ProjectIssuesSerializers

class IssueView(viewsets.ModelViewSet):
    queryset = Issue.objects.all()
    serializer_class = IssueSerializer

class CommentView(viewsets.ModelViewSet):
    queryset = Comment.objects.all()
    serializer_class = CommentSerializer

class Register(generics.CreateAPIView):
    queryset = ''
    serializer_class = UserSerializer
    permission_classes = (permissions.AllowAny,)
    
    def post(self, request):
        if request.method == 'POST':
            data = request.data
            serializer = UserSerializer(data=data)
            if serializer.is_valid():
                User.objects.create_user(data['username'], data['email'], data['password'])
                return Response({"message": ["User has been created."]}, status=status.HTTP_201_CREATED)
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class UserInfo(APIView):
    def post(self, request, format=None):
        try:
            user_info = User.objects.get(id=request.data['user_id'])
            serializer = UserInfoSerializer(user_info, many=False)
            return Response(serializer.data)
        except User.DoesNotExist:
            return Response({"message": ["Something went wrong."]}, status=status.HTTP_400_BAD_REQUEST)
