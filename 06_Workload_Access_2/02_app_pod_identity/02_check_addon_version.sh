#!/bin/bash

if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

ADDON_NAME=eks-pod-identity-agent
# ==================================================================

echo "aws eks describe-addon-versions --kubernetes-version ${EKS_VERSION} \\
    --addon-name ${ADDON_NAME} \\
    --query 'addons[].addonVersions[].{Version: addonVersion, Defaultversion: compatibilities[0].defaultVersion}' \\
    --output table ${PROFILE_STRING}"

aws eks describe-addon-versions --kubernetes-version ${EKS_VERSION} \
    --addon-name ${ADDON_NAME} \
    --query 'addons[].addonVersions[].{Version: addonVersion, Defaultversion: compatibilities[0].defaultVersion}' \
    --output table ${PROFILE_STRING}

echo "[TODO] 설치할 Version을 기록해 두세요.!!"