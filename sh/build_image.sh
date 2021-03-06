#!/bin/bash
set -e

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"

docker build \
  --tag cyberdojofoundation/images_info \
    ${ROOT_DIR}
