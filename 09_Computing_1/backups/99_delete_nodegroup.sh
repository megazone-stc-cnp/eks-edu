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

OPS_NODE_NAME=eks-edu-ops-node
APP_NODE_NAME=eks-edu-app-node
# ==================================================================
echo "eksctl delete nodegroup \\
  --cluster ${CLUSTER_NAME} \\
  --name ${OPS_NODE_NAME} ${PROFILE_STRING}"

eksctl delete nodegroup \
  --cluster ${CLUSTER_NAME} \
  --name ${OPS_NODE_NAME} ${PROFILE_STRING}
