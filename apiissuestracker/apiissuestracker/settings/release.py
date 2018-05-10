from .base import *
import os

# Disable debug
DEBUG = False

# Must be explicitly specified when Debug is disabled
ALLOWED_HOSTS = [os.environ.get('ALLOWED_HOSTS', '*')]

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': os.environ.get('MYSQL_DATABASE', '<DATABASE>'),
        'USER': os.environ.get('MYSQL_USER', '<USER>'),
        'PASSWORD': os.environ.get('MYSQL_PASSWORD', '<SECRET>'),
        'HOST': os.environ.get('MYSQL_HOST', '<HOST>'),
        'PORT': os.environ.get('MYSQL_PORT', '<PORT>'),
        'OPTIONS': {
            'sql_mode': 'traditional',
        },
    }
}
