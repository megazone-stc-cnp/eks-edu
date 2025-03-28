#!/bin/bash

if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh

if ! command -v docker &> /dev/null; then
    echo "docker가 설치되어 있지 않습니다."
    exit 1
fi
# AWS_REPO_ACCOUNT=539666729110
REPO_FULLPATH=registry.k8s.io/autoscaling/cluster-autoscaler
ORIGIN_TAG=v1.32.0
# ==================================================================

aws ecr create-repository \
    --repository-name ${REPO_FULLPATH} \
    --region ${AWS_REGION} ${PROFILE_STRING}