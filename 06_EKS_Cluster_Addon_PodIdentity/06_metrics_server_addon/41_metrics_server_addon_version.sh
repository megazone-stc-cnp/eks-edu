#!/bin/bash
#
. ../env.sh
# export AWS_REGION=ap-northeast-1
# export EMPLOY_ID=9641173
# export PROFILE_NAME=cnp-key
# export AWS_REPO_ACCOUNT=539666729110
# export CLUSTER_NAME=eks-edu-cluster-${EMPLOY_ID}
# export EKS_VERSION

ADDON_NAME=metrics-server
# ============================================================

echo "aws eks describe-addon-versions --kubernetes-version ${EKS_VERSION} \\
    --addon-name ${ADDON_NAME} \\
    --query 'addons[].addonVersions[].{Version: addonVersion, Defaultversion: compatibilities[0].defaultVersion}' --output table \\
    --region ${AWS_REGION} ${PROFILE_STRING}"

aws eks describe-addon-versions --kubernetes-version ${EKS_VERSION} \
    --addon-name ${ADDON_NAME} \
    --query 'addons[].addonVersions[].{Version: addonVersion, Defaultversion: compatibilities[0].defaultVersion}' --output table \
    --region ${AWS_REGION} ${PROFILE_STRING}

echo "NOTICE: 설치할 버전을 저장해 두세요 !!"