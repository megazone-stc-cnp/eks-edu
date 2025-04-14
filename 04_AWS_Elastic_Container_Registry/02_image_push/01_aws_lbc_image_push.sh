#!/bin/bash

if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

if ! command -v docker &> /dev/null; then
    echo "[ERROR] docker가 설치되어 있지 않습니다."
    exit 1
fi

REPO_FULLPATH=public.ecr.aws/eks/aws-load-balancer-controller
TARGET_REPO_FULLPATH=public.ecr.aws/eks-${IDE_NAME}/aws-load-balancer-controller
ORIGIN_TAG=v2.9.2
# ==================================================================
ORIGIN_IMG=${REPO_FULLPATH}:${ORIGIN_TAG}
PRIVATE_ECR=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
PRIVATE_ECR_IMG=$PRIVATE_ECR/$TARGET_REPO_FULLPATH:${ORIGIN_TAG}

# Check if the CPU architecture is ARM-based

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