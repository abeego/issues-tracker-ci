#!/bin/bash

# Activate virtual environment
. /appenv/bin/activate

# Downloads requireemnts to build cache
pip download -d /build -r requirements_test.txt --no-input

# Install application test requireemnts (uses packages from /build cache and install)
pip install --no-index -f /build -r requirements_test.txt

# Run test.sh arguments
exec $@
