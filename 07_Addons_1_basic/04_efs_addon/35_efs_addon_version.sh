#!/bin/bash
if [ ! -f "./local_env.sh" ];then
	echo "local_env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ./local_env.sh
# export OIDC_ID=0A7E9D9D443319C0B6469DEA0A371292

if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh

ADDON_NAME=aws-efs-csi-driver
# ===============================================
aws eks describe-addon-versions --kubernetes-version ${EKS_VERSION} --addon-name ${ADDON_NAME} \
    --query 'addons[].addonVersions[].{Version: addonVersion, Defaultversion: compatibilities[0].defaultVersion}' --output table ${PROFILE_STRING}

echo "Version을 저장하세요 !!!"