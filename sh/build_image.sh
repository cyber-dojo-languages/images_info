#!/bin/bash
set -e

# This builds the main 'outer' images_info docker-image
# which includes docker-compose inside it.

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"

docker build \
  --build-arg DOCKER_COMPOSE_VERSION=1.11.1 \
  --tag cyberdojofoundation/images_info \
    ${ROOT_DIR}

${ROOT_DIR}/app/build-docker-image.sh