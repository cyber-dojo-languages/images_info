#!/bin/bash
set -e

readonly SH_DIR="$( cd "$( dirname "${0}" )" && pwd )/sh"

${SH_DIR}/build_image.sh
${SH_DIR}/test_image.sh
