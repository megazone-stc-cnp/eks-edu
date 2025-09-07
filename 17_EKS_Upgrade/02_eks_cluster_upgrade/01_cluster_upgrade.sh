#!/bin/bash

if [ -z "$1" ]; then
    echo "사용법: $0 <UPGRADE_VERSION>"
    exit 1
fi
EKS_TARGET_VERSION=$1

if [ ! -f "../../env.sh" ];then
  echo "env.sh 파일 세팅을 해주세요."
  exit 1
fi
. ../../env.sh

# ==============================================================
aws eks update-cluster-version \
    --name ${EKS_CLUSTER_NAME}  \
    --kubernetes-version ${EKS_TARGET_VERSION} \
    --region ${REGION_NAME} \
    --profile ${PROFILE_NAME}

echo "Upgrade ID 값을 카피해서 업그레이드 진행 상태 체크시 사용하세요"