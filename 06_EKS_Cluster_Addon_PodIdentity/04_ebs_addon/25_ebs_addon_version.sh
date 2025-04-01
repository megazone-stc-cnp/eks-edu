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
# export AWS_REGION=ap-northeast-1
# export EMPLOY_ID=9641173
# export PROFILE_NAME=cnp-key
# export AWS_REPO_ACCOUNT=539666729110
# export HOME_DIR=/Users/mzc01-hcseo/00_PARA/01_project/autoever-eks-edu/source/eks-edu
# export EKS_VERSION=1.31
# export CLUSTER_NAME=eks-edu-cluster-${EMPLOY_ID}
ADDON_NAME=aws-ebs-csi-driver
# ===============================================
aws eks describe-addon-versions --kubernetes-version ${EKS_VERSION} --addon-name ${ADDON_NAME} \
    --query 'addons[].addonVersions[].{Version: addonVersion, Defaultversion: compatibilities[0].defaultVersion}' --output table \
    --region ${AWS_REGION} ${PROFILE_STRING}

echo "Version을 저장하세요 !!!"