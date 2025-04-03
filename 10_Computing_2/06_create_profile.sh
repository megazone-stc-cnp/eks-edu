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
POD_EXECUTION_ROLE_NAME=eks-edu-fargate-execution-role-${IDE_NAME}
# ============================================================================

echo "aws eks create-fargate-profile \\
  --cluster-name ${CLUSTER_NAME} \\
  --pod-execution-role-arn arn:aws:iam::${AWS_ACCOUNT_ID}:role/${POD_EXECUTION_ROLE_NAME} \\
  --fargate-profile-name ${FARGATE_PROFILE_NAME} \\
  --selectors '[{\"namespace\": \"${NAMESPACE_NAME}\"}]' \\
  --subnets '[\"${AWS_PRIVATE_SUBNET1}\", \"'${AWS_PRIVATE_SUBNET2}\"]' ${PROFILE_STRING}"

aws eks create-fargate-profile \
    --cluster-name ${CLUSTER_NAME} \
    --pod-execution-role-arn arn:aws:iam::${AWS_ACCOUNT_ID}:role/${POD_EXECUTION_ROLE_NAME} \
    --fargate-profile-name ${FARGATE_PROFILE_NAME} \
    --selectors "[{\"namespace\": \"${NAMESPACE_NAME}\"}]" \
    --subnets "[\"${AWS_PRIVATE_SUBNET1}\", \"${AWS_PRIVATE_SUBNET2}\"]" ${PROFILE_STRING}

echo "${FARGATE_PROFILE_NAME} 생성중"

echo "aws eks wait fargate-profile-active \\
    --cluster-name ${CLUSTER_NAME} \\
    --fargate-profile-name ${FARGATE_PROFILE_NAME} ${PROFILE_STRING}"

aws eks wait fargate-profile-active \
    --cluster-name ${CLUSTER_NAME} \
    --fargate-profile-name ${FARGATE_PROFILE_NAME} ${PROFILE_STRING}
echo "${FARGATE_PROFILE_NAME} 생성 완료"