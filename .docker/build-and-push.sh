#!/usr/bin/env bash

set -e

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

cd $SCRIPT_DIR/.. && docker build \
  --build-arg VCS_URL=`git remote get-url origin` \
  --build-arg VCS_REF=`git rev-parse --short HEAD` \
  --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
  --build-arg NAME=minsk-core-ci \
  -t visortelle/node-docker:latest .

echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
docker push visortelle/node-docker:latest
