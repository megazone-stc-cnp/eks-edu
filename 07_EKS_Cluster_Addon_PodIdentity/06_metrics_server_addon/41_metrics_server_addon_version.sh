#!/bin/bash
#
. ../env.sh

ADDON_NAME=metrics-server
# ============================================================

echo "aws eks describe-addon-versions --kubernetes-version ${EKS_VERSION} \\
    --addon-name ${ADDON_NAME} \\
    --query 'addons[].addonVersions[].{Version: addonVersion, Defaultversion: compatibilities[0].defaultVersion}' --output table ${PROFILE_STRING}"

aws eks describe-addon-versions --kubernetes-version ${EKS_VERSION} \
    --addon-name ${ADDON_NAME} \
    --query 'addons[].addonVersions[].{Version: addonVersion, Defaultversion: compatibilities[0].defaultVersion}' --output table ${PROFILE_STRING}

echo "NOTICE: 설치할 버전을 저장해 두세요 !!"