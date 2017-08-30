#!/bin/bash
set -e

# This builds the main 'outer' images_info docker-image
# which includes docker-compose inside it.

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"

docker build \
  --tag cyberdojofoundation/images_info \
    ${ROOT_DIR}
