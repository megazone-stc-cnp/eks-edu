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
NODE_NAME=ip-100-124-26-57.ap-northeast-2.compute.internal
kubectl cordon ${NODE_NAME}
kubectl drain ${NODE_NAME} --ignore-daemonsets --delete-emptydir-data