FROM abeego/issues-tracker-base:latest

# Install dev/build dependencies
RUN apk update && \
  apk add --no-cache python3-dev

RUN . /appenv/bin/activate && \
  pip install wheel --upgrade

# PIP environment variables (NOTE: must be set after installing wheel)
ENV WHEELHOUSE=/wheelhouse PIP_WHEEL_DIR=/wheelhouse PIP_FIND_LINKS=/wheelhouse XGD_CACHE_HOME=/cache

# OUTPUT: Build artefact are output here
VOLUME /wheelhouse

# OUTPUT: Build cache
VOLUME /build

# OUTPUT: Test reports are output here
VOLUME /reports

COPY scripts/test.sh /usr/local/bin/test.sh
RUN chmod +x /usr/local/bin/test.sh

# Overide base entrypoint
ENTRYPOINT ["test.sh"]
CMD ["python", "manage.py", "test", "--noinput"]

COPY apiissuestracker /application
WORKDIR /application
