#!/bin/bash
if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh

if [ ! -f "./local_env.sh" ];then
	echo "local_env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ./local_env.sh
# export VPC_ID=vpc-09effdadb2d737300
# export AWS_AZ1=ap-northeast-1a
# export AWS_AZ2=ap-northeast-1c
# export AWS_PRIVATE_SUBNET1=subnet-03ed17397746222a8
# export AWS_PRIVATE_SUBNET2=subnet-07873917f6e87880b
# export EKS_ADDITIONAL_SG=sg-033a4c5fa9437d100

NAMESPACE_NAME=app
FARGATE_PROFILE_NAME=app-ns
REPOSITORY_PREFIX=public-ecr-${IDE_NAME}
UPSTREAM_REPOSITORY_NAME=nginx/nginx
TAG_NAME=1.27
# ============================================================================
ECR_URI=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPOSITORY_PREFIX}/${UPSTREAM_REPOSITORY_NAME}

echo "kubectl -n ${NAMESPACE_NAME} create deploy app --image=${ECR_URI}:${TAG_NAME} --port=80"
kubectl -n ${NAMESPACE_NAME} create deploy app --image=${ECR_URI}:${TAG_NAME} --port=80

echo "kubectl -n ${NAMESPACE_NAME} describe pods"
kubectl -n ${NAMESPACE_NAME} describe pods

echo "kubectl get nodes"
kubectl get nodes