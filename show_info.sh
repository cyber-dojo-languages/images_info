#!/bin/bash

readonly SRC_DIR=${1:-${PWD}}
readonly BASE_DIR=$(dirname ${SRC_DIR})

docker run \
  --user=root \
  --rm \
  --interactive \
  --tty \
  --env SRC_DIR=${SRC_DIR} \
  --volume=${BASE_DIR}:${BASE_DIR}:ro \
    cyberdojofoundation/images_info \
      /app/main.rb > images_info.json

cat images_info.json
