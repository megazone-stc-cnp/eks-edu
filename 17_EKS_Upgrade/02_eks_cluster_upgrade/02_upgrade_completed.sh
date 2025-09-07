#!/bin/bash

if [ -z "$1" ]; then
    echo "사용법: $0 <UPGRADE_ID>"
    exit 1
fi
UPGRADE_ID=$1

if [ ! -f "../../env.sh" ];then
  echo "env.sh 파일 세팅을 해주세요."
  exit 1
fi
. ../../env.sh

# ==============================================================

aws eks describe-update \
    --name ${CLUSTER_NAME}  \
    --update-id ${UPGRADE_ID} \
    --region ${AWS_REGION} \
    --profile ${PROFILE_NAME}

