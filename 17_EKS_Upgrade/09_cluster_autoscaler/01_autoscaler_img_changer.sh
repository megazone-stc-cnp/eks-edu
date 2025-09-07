#!/bin/bash

if [ ! -f "../../env.sh" ];then
  echo "env.sh 파일 세팅을 해주세요."
  exit 1
fi
. ../../env.sh

AWS_ECR_REPO_NAME=eks/cluster-autoscaler
# ==============================================================

img_repo_change() {
  REPO_FULLPATH=$1
  IMG_TAG=$2
  ORIGIN_IMG=$REPO_FULLPATH:$IMG_TAG
  # OLD_AWS_ECR_REPO_NAME=$(echo $ORIGIN_IMG | cut -d '/' -f2- | cut -d ':' -f1)
  PRIVATE_ECR=$ACCOUNT_ID.dkr.ecr.${AWS_REGION}.amazonaws.com
  PRIVATE_ECR_IMG=$PRIVATE_ECR/$AWS_ECR_REPO_NAME:$IMG_TAG

  echo $AWS_ECR_REPO_NAME
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
  aws ${PROFILE_STRING} ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin $PRIVATE_ECR
  "

  aws ${PROFILE_STRING} ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin $PRIVATE_ECR

  # Image Tag Change
  docker tag $ORIGIN_IMG $PRIVATE_ECR_IMG

  # Image Push
  docker push $PRIVATE_ECR_IMG

  # Image Remove
  docker rmi $PRIVATE_ECR_IMG $ORIGIN_IMG
}

upload_autoscaler() {
  IMG_TAG=$1
  img_repo_change registry.k8s.io/autoscaling/cluster-autoscaler $IMG_TAG
}

# IMG Version
upload_autoscaler v1.30.0