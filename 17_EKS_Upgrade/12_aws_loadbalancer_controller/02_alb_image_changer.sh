#!/bin/bash

if [ ! -f "../../env.sh" ];then
  echo "env.sh 파일 세팅을 해주세요."
  exit 1
fi
. ../../env.sh

# 1.29 : IMAGE_VERSION=v2.8.1
# 1.31 : IMAGE_VERSION=v2.11.0
IMAGE_VERSION=v2.11.0
# =====================================================================
# 741466665369.dkr.ecr.ap-northeast-2.amazonaws.com/eks/aws-load-balancer-controller
PROFILE_STRING=""
if [ -n "$PROFILE_NAME" ]; then
    PROFILE_STRING="--profile ${AWS_REPO_PROFILE}"
fi
img_repo_change() {
  REPO_FULLPATH=$1
  IMG_TAG=$2
  ORIGIN_IMG=$REPO_FULLPATH:$IMG_TAG
  REPO_NAME=$(echo $ORIGIN_IMG | cut -d '/' -f2- | cut -d ':' -f1)
  PRIVATE_ECR=$ACCOUNT_ID.dkr.ecr.${AWS_REGION}.amazonaws.com
  PRIVATE_ECR_IMG=$PRIVATE_ECR/$REPO_NAME:$IMG_TAG

  echo $REPO_NAME
  echo $IMG_TAG
  echo $PRIVATE_ECR

  # Iamge Pull
  echo "Origin Image Pull
  docker pull "$ORIGIN_IMG"
  "
  docker pull $ORIGIN_IMG

  # ECR Login
  echo "
  # Docker Login
  aws ${PROFILE_STRING} ecr get-login-password --region $REGION_NAME | docker login --username AWS --password-stdin $PRIVATE_ECR
  "
  aws ${PROFILE_STRING} ecr get-login-password --region $REGION_NAME | docker login --username AWS --password-stdin $PRIVATE_ECR

  # Image Tag Change
  docker tag $ORIGIN_IMG $PRIVATE_ECR_IMG

  # Image Push
  docker push $PRIVATE_ECR_IMG

  # Image Remove
  docker rmi $PRIVATE_ECR_IMG $ORIGIN_IMG
}

upload_lb_controller() {
  IMG_TAG=$1
  img_repo_change public.ecr.aws/eks/aws-load-balancer-controller $IMG_TAG
}

# IMG Version
upload_lb_controller ${IMAGE_VERSION}