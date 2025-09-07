#!/bin/bash

if [ -z "$1" ]; then
    echo "사용법: $0 <node-name>"
    exit 1
fi
NODE_NAME=$1

if [ ! -f "../../env.sh" ];then
  echo "env.sh 파일 세팅을 해주세요."
  exit 1
fi
. ../../env.sh

# ==================================================================
aws eks describe-nodegroup \
    --cluster-name ${EKS_CLUSTER_NAME} \
    --nodegroup-name ${NODE_NAME} \
    --region ${AWS_REGION} \
    --profile ${PROFILE_NAME}  