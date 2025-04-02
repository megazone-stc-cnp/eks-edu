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
# AWS_REPO_ACCOUNT=539666729110
REPO_FULLPATH=registry.k8s.io/autoscaling/cluster-autoscaler
ORIGIN_TAG=v1.32.0
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