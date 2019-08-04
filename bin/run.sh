#!/usr/bin/env bash
set -ev

docker build . -t thingiverse

docker run -it --rm \
-v "${pwd}:/usr/src/tv" \
thingiverse "$@"
