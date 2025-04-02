#!/bin/bash
if [ -z "$1" ]; then
    echo "사용법: $0 <ADDON_VERSION>"
    exit 1
fi
ADDON_VERSION=$1

. ../env.sh
# export AWS_REGION=ap-northeast-1
# export IDE_NAME=9641173
# export PROFILE_NAME=cnp-key
# export AWS_REPO_ACCOUNT=539666729110
# export HOME_DIR=/Users/mzc01-hcseo/00_PARA/01_project/autoever-eks-edu/source/eks-edu
# export EKS_VERSION=1.31
# export CLUSTER_NAME=eks-edu-cluster-${IDE_NAME}

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