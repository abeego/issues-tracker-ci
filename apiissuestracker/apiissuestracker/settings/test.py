from .base import *
import os

INSTALLED_APPS += ('django_nose',)
TEST_RUNNER = 'django_nose.NoseTestSuiteRunner'
TEST_OUTPUT_DIR = os.environ.get('TEST_OUTPUT_DIR', '.')
NOSE_ARGS = [
  '--verbosity=2',                  # verbose output
  '--nologcapture',                 # don't output log capture
  '--with-coverage',                # activate coverage report
  '--cover-package=api',           # coverage reports will apply to these packages
  '--with-spec',                    # spec style tests
  '--spec-color',
  '--with-xunit',                   # enable xunit plugin
  '--xunit-file=%s/unittests.xml' % TEST_OUTPUT_DIR,
  '--cover-xml',                    # produce XML coverage info
  '--cover-xml-file=%s/coverage.xml' % TEST_OUTPUT_DIR,
]

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': os.environ.get('MYSQL_NAME', '<DATABASE>'),
        'USER': os.environ.get('MYSQL_USER', '<USER>'),
        'PASSWORD': os.environ.get('MYSQL_PASSWORD', '<SECRET>'),
        'HOST': os.environ.get('MYSQL_HOST', '<HOST>'),
        'PORT': os.environ.get('MYSQL_PORT', '<PORT>'),
    }
}
