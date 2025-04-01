#!/bin/bash

if [ -z "$1" ]; then
    echo "사용법: $0 <ADDON_VERSION>"
    exit 1
fi
ADDON_VERSION=$1

. ../env.sh
# export AWS_REGION=ap-northeast-1
# export EMPLOY_ID=9641173
# export PROFILE_NAME=cnp-key
# export AWS_REPO_ACCOUNT=539666729110
# export HOME_DIR=/Users/mzc01-hcseo/00_PARA/01_project/autoever-eks-edu/source/eks-edu
# export EKS_VERSION=1.31

ADDON_NAME=metrics-server
# ============================================

echo "aws eks describe-addon-configuration \\
    --addon-name ${ADDON_NAME} \\
    --addon-version ${ADDON_VERSION} \\
    --region ${AWS_REGION} ${PROFILE_NAME}"

aws eks describe-addon-configuration \
    --addon-name ${ADDON_NAME} \
    --addon-version ${ADDON_VERSION} \
    --region ${AWS_REGION} ${PROFILE_STRING}