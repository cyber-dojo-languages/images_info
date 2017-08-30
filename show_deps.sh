#!/bin/bash

readonly SRC_DIR=${1:-${PWD}}

if [ ! -z "${TRAVIS}" ]; then
  #echo 'Running on TRAVIS'
  readonly BASE_DIR=${SRC_DIR}
else
  #echo 'Running locally'
  readonly BASE_DIR=$(dirname ${SRC_DIR})
fi

docker run \
  --user=root \
  --network=${NETWORK} \
  --rm \
  --interactive \
  --tty \
  --env DOCKER_USERNAME \
  --env DOCKER_PASSWORD \
  --env GITHUB_TOKEN \
  --env SRC_DIR=${SRC_DIR} \
  --env TRAVIS \
  --env TRAVIS_REPO_SLUG \
  --volume=${BASE_DIR}:${BASE_DIR}:ro \
  --volume=/var/run/docker.sock:/var/run/docker.sock \
    cyberdojofoundation/images_info \
      /app/main.rb
