FROM abeego/issues-tracker-base:latest

# Copy application artefacts
COPY target /wheelhouse

# Install application
RUN . /appenv/bin/activate && \
  pip install --no-index -f /wheelhouse apiissuestracker && \
  rm -rf /wheelhouse
