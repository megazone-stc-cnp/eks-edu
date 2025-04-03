#!/bin/bash
if [ -z "$1" ]; then
    echo "사용법: $0 <ADDON_VERSION>"
    exit 1
fi
ADDON_VERSION=$1

. ../env.sh

ADDON_NAME=metrics-server
# ============================================

echo "aws eks create-addon \\
    --cluster-name ${CLUSTER_NAME} \\
    --addon-name ${ADDON_NAME} \\
    --addon-version ${ADDON_VERSION} \\
    --resolve-conflicts OVERWRITE ${PROFILE_STRING}"

aws eks create-addon \
    --cluster-name ${CLUSTER_NAME} \
    --addon-name ${ADDON_NAME} \
    --addon-version ${ADDON_VERSION} \
    --resolve-conflicts OVERWRITE ${PROFILE_STRING}