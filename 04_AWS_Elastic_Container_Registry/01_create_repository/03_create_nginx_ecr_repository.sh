#!/bin/bash

if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh
# export AWS_REGION=ap-northeast-1
# export IDE_NAME=9641173
# export PROFILE_NAME=cnp-key
# export AWS_REPO_ACCOUNT=539666729110
# export HOME_DIR=/Users/mzc01-hcseo/00_PARA/01_project/autoever-eks-edu/source/eks-edu
# export EKS_VERSION=1.31

if ! command -v docker &> /dev/null; then
    echo "docker가 설치되어 있지 않습니다."
    exit 1
fi
# AWS_REPO_ACCOUNT=539666729110
REPO_FULLPATH=public.ecr.aws/nginx/nginx
# ==================================================================
if aws ecr describe-repositories --repository-names ${REPO_FULLPATH} ${PROFILE_STRING} &> /dev/null; then
    echo "ECR repository ${REPO_FULLPATH} already exists. Skipping creation."
else
    echo "aws ecr create-repository \\
        --repository-name ${REPO_FULLPATH} ${PROFILE_STRING}"

    aws ecr create-repository \
        --repository-name ${REPO_FULLPATH} ${PROFILE_STRING}
fi