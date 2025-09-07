#!/bin/bash

if [ ! -f "../../env.sh" ];then
  echo "env.sh 파일 세팅을 해주세요."
  exit 1
fi
. ../../env.sh

ADDON_NAME=kube-proxy
# ================================
echo "aws eks describe-addon-versions --kubernetes-version ${EKS_UPGRADE_CLUSTER_VERSION} \\
    --addon-name ${ADDON_NAME} \\
    --query 'addons[].addonVersions[].{Version: addonVersion, Defaultversion: compatibilities[0].defaultVersion}' --output table ${PROFILE_STRING}"

aws eks describe-addon-versions --kubernetes-version ${EKS_UPGRADE_CLUSTER_VERSION} \
    --addon-name ${ADDON_NAME} \
    --query 'addons[].addonVersions[].{Version: addonVersion, Defaultversion: compatibilities[0].defaultVersion}' --output table ${PROFILE_STRING}
