#!/bin/bash

if [ -z "$1" ]; then
    echo "사용법: $0 <id>"
    exit 1
fi
ID=$1

if [ ! -f "../../env.sh" ];then
  echo "env.sh 파일 세팅을 해주세요."
  exit 1
fi
. ../../env.sh

# ==============================================================

aws eks describe-insight \
    --region $AWS_REGION \
    --id ${ID} \
    --cluster-name ${EKS_CLUSTER_NAME} ${PROFILE_STRING}