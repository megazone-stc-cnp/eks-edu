#!/bin/bash

if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

if ! command -v docker &> /dev/null; then
    echo "docker가 설치되어 있지 않습니다."
    exit 1
fi

REPO_FULLPATH=registry.k8s.io/autoscaling-${IDE_NAME}/cluster-autoscaler
# ==================================================================

if aws ecr describe-repositories --repository-names ${REPO_FULLPATH} ${PROFILE_STRING} &> /dev/null; then
    echo "ECR repository ${REPO_FULLPATH} already exists. Skipping creation."
else
    echo "aws ecr create-repository \\
        --repository-name ${REPO_FULLPATH} ${PROFILE_STRING}"

    aws ecr create-repository \
        --repository-name ${REPO_FULLPATH} ${PROFILE_STRING}
fi