#!/bin/bash

if [ -z "$1" ]; then
    echo "사용법: $0 <ADDON_VERSION>"
    exit 1
fi
ADDON_VERSION=$1

. ../env.sh

ADDON_NAME=metrics-server
# ============================================

echo "aws eks describe-addon-configuration \\
    --addon-name ${ADDON_NAME} \\
    --addon-version ${ADDON_VERSION} ${PROFILE_NAME}"

aws eks describe-addon-configuration \
    --addon-name ${ADDON_NAME} \
    --addon-version ${ADDON_VERSION} ${PROFILE_STRING}