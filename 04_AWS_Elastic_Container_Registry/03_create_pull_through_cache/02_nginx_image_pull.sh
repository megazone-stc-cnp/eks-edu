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

REPOSITORY_PREFIX=public-ecr-${IDE_NAME}
REPO_PATH=nginx/nginx
ORIGIN_TAG=1.27
# ==================================================================
PRIVATE_ECR=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

echo "aws ecr get-login-password --region ${AWS_REGION} ${PROFILE_STRING} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

echo "docker pull ${PRIVATE_ECR}/${REPOSITORY_PREFIX}/${REPO_PATH}:${ORIGIN_TAG}"

aws ecr get-login-password --region ${AWS_REGION} ${PROFILE_STRING} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

docker pull ${PRIVATE_ECR}/${REPOSITORY_PREFIX}/${REPO_PATH}:${ORIGIN_TAG}