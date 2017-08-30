#!/bin/bash
set -e

readonly ORG_NAME=cyberdojofoundation

docker login \
  --username ${DOCKER_USERNAME} \
  --password ${DOCKER_PASSWORD}

docker push ${ORG_NAME}/images_info
