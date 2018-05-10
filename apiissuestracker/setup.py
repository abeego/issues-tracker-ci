from setuptools import setup, find_packages

setup(
    name                        = "apiissuestracker",
    version                     = "0.1.0",
    description                 = "Issues Tracker REST Service",
    packages                    = find_packages(),
    include_package_data        = True,
    scripts                     = ["manage.py"],
    install_requires            = [
                                    "Django==2.0.4",
                                    "django-cors==0.1",
                                    "django-cors-headers==2.2.0",
                                    "django-filter==1.1.0",
                                    "djangorestframework==3.8.2",
                                    "djangorestframework-simplejwt==3.2.3",
                                    "mysqlclient==1.3.12",
                                    "PyJWT==1.6.1",
                                    "pytz==2018.4",
                                    "uwsgi==2.0.17"
                                  ],
    extras_require              = {
                                    "test": [
                                        "colorama==0.3.9",
                                        "coverage==4.0.3",
                                        "django-nose==1.4.5",
                                        "nose==1.3.7",
                                        "pinocchio==0.4.2",
                                    ]
                                  }
)
