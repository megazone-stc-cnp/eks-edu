#!/bin/bash

if [ ! -f "../../env.sh" ];then
  echo "env.sh 파일 세팅을 해주세요."
  exit 1
fi
. ../../env.sh

if [ ! -f "../upgrade_env.sh" ];then
  echo "upgrade_env.sh 파일 세팅을 해주세요."
  exit 1
fi
. ../upgrade_env.sh

ADDON_NAME=aws-ebs-csi-driver
# ================================
echo aws eks describe-addon-versions --kubernetes-version ${EKS_UPGRADE_CLUSTER_VERSION} --addon-name ${ADDON_NAME} --query 'addons[].addonVersions[].{Version: addonVersion, Defaultversion: compatibilities[0].defaultVersion}' --output json ${PROFILE_STRING}
aws eks describe-addon-versions --kubernetes-version ${EKS_UPGRADE_CLUSTER_VERSION} \
    --addon-name ${ADDON_NAME} \
    --query 'addons[].addonVersions[].{Version: addonVersion, Defaultversion: compatibilities[0].defaultVersion}' --output json ${PROFILE_STRING}