#!/bin/bash

if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh
# export AWS_REGION=ap-northeast-1
# export EMPLOY_ID=9641173
# export PROFILE_NAME=cnp-key
# export AWS_REPO_ACCOUNT=539666729110
# export HOME_DIR=/Users/mzc01-hcseo/00_PARA/01_project/autoever-eks-edu/source/eks-edu
# export EKS_VERSION=1.31

if ! command -v docker &> /dev/null; then
    echo "docker가 설치되어 있지 않습니다."
    exit 1
fi
# AWS_REPO_ACCOUNT=539666729110
REPOSITORY_PREFIX=public-ecr-${EMPLOY_ID}
UPSTREAM_REPOSITORY_NAME=nginx/nginx
# ==================================================================
echo "aws ecr create-repository \\
    --repository-name ${REPOSITORY_PREFIX}/${UPSTREAM_REPOSITORY_NAME} \\
    --region ${AWS_REGION} ${PROFILE_STRING}"

aws ecr create-repository \
    --repository-name ${REPOSITORY_PREFIX}/${UPSTREAM_REPOSITORY_NAME} \
    --region ${AWS_REGION} ${PROFILE_STRING}