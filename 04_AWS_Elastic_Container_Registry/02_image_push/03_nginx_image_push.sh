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
ORIGIN_TAG=1.27
# ==================================================================
ORIGIN_IMG=${REPO_FULLPATH}:${ORIGIN_TAG}
PRIVATE_ECR=${AWS_REPO_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com
PRIVATE_ECR_IMG=$PRIVATE_ECR/$REPO_FULLPATH:${ORIGIN_TAG}

echo "docker pull ${ORIGIN_IMG}"
echo "aws ecr get-login-password ${PROFILE_STRING} | docker login --username AWS --password-stdin $PRIVATE_ECR"

echo "docker tag $ORIGIN_IMG $PRIVATE_ECR_IMG"

# Image Push
echo "docker push $PRIVATE_ECR_IMG"

# Image Remove
echo "docker rmi $PRIVATE_ECR_IMG $ORIGIN_IMG"

docker pull ${ORIGIN_IMG}
aws ecr get-login-password ${PROFILE_STRING} | docker login --username AWS --password-stdin $PRIVATE_ECR

docker tag $ORIGIN_IMG $PRIVATE_ECR_IMG

# Image Push
docker push $PRIVATE_ECR_IMG

# Image Remove
docker rmi $PRIVATE_ECR_IMG $ORIGIN_IMG