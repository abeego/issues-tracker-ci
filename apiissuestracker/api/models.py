from django.db import models

class Project(models.Model):
    name = models.CharField(max_length=100, blank=False, default='', unique=True)
    description = models.CharField(max_length=255)
    created_at = models.DateTimeField(auto_now_add=True, unique=True)

    class Meta:
        # Order by created_at descending
        ordering = ('-created_at',)

    def __str__(self):
        return self.name


class Issue(models.Model):
    PLANED = 'Planed'
    INPROGRESS = 'In Progress'
    RESOLVED = 'Resolved'
    VERIFIED = 'Verified'
    DONE = 'Done'
    STATUSES = (
        (PLANED, 'Planed'),
        (INPROGRESS, 'In Progress'),
        (RESOLVED, 'Resolved'),
        (VERIFIED, 'Verified'),
        (DONE, 'Done'),
    )
    name = models.CharField(max_length=100, blank=False, default='', unique=True)
    description = models.CharField(max_length=255)
    status = models.CharField(
        max_length=12,
        choices=STATUSES,
        default=PLANED,
    )
    created_at = models.DateTimeField(auto_now_add=True, unique=True)
    project = models.ForeignKey(Project, related_name='issues', on_delete=models.CASCADE)

    class Meta:
        # Order by score descending
        ordering = ('-created_at',)

    def __str__(self):
        return self.name


class Comment(models.Model):
    body = models.CharField(max_length=255)
    created_at = models.DateTimeField(auto_now_add=True, unique=True)
    issue = models.ForeignKey(Issue, related_name='comments', on_delete=models.CASCADE)

    class Meta:
        # Order by score descending
        ordering = ('-created_at',)

    def __str__(self):
        return self.created_at
