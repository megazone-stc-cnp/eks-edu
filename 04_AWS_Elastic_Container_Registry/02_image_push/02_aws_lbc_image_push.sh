#!/bin/bash

if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh

if ! command -v docker &> /dev/null; then
    echo "[ERROR] docker가 설치되어 있지 않습니다."
    exit 1
fi
# AWS_REPO_ACCOUNT=539666729110
REPO_FULLPATH=public.ecr.aws/eks/aws-load-balancer-controller
ORIGIN_TAG=v2.9.2

# ==================================================================

ORIGIN_IMG=${REPO_FULLPATH}:${ORIGIN_TAG}
PRIVATE_ECR=${AWS_REPO_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com
PRIVATE_ECR_IMG=$PRIVATE_ECR/$REPO_FULLPATH:${ORIGIN_TAG}

# Check if the CPU architecture is ARM-based
if [[ $(uname -m) == "arm"* ]] || [[ $(uname -m) == "aarch64" ]]; then
    echo "docker pull ${ORIGIN_IMG}"
    echo "aws ecr get-login-password \\
        --region ${AWS_REGION} | docker login --username AWS --password-stdin $PRIVATE_ECR"

    echo "docker tag $ORIGIN_IMG $PRIVATE_ECR_IMG"

    # Image Push
    echo "docker push $PRIVATE_ECR_IMG"

    # Image Remove
    echo "docker rmi $PRIVATE_ECR_IMG $ORIGIN_IMG"

    echo "[ERROR] Arm 계열을 CPU 입니다. AMD64 계열의 CPU에서 업로드 하세요."
    exit 1
fi

docker pull ${ORIGIN_IMG}
aws ecr get-login-password \
    --region ${AWS_REGION} ${PROFILE_STRING} | docker login --username AWS --password-stdin $PRIVATE_ECR

docker tag $ORIGIN_IMG $PRIVATE_ECR_IMG

# Image Push
docker push $PRIVATE_ECR_IMG

# Image Remove
docker rmi $PRIVATE_ECR_IMG $ORIGIN_IMG