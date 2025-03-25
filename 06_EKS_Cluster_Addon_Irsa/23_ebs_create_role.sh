#!/bin/bash
#
if [ ! -f "./local_env.sh" ];then
	echo "local_env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ./local_env.sh
# export OIDC_ID=0A7E9D9D443319C0B6469DEA0A371292

if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh
# export AWS_REGION=ap-northeast-1
# export EMPLOY_ID=9641173
# export PROFILE_NAME=cnp-key
# export AWS_REPO_ACCOUNT=539666729110
# export HOME_DIR=/Users/mzc01-hcseo/00_PARA/01_project/autoever-eks-edu/source/eks-edu
# export EKS_VERSION=1.31
# export CLUSTER_NAME=eks-edu-cluster-${EMPLOY_ID}
EBS_ROLE_NAME=eks-edu-ebs-irsa-role-${EMPLOY_ID}
# ===============================================
echo "aws iam create-role \\
  --role-name ${EBS_ROLE_NAME} \\
  --assume-role-policy-document file://"aws-ebs-csi-driver-trust-policy.json" ${PROFILE_STRING}"

echo "${EBS_ROLE_NAME} role 생성중"
aws iam create-role \
  --role-name ${EBS_ROLE_NAME} \
  --assume-role-policy-document file://"aws-ebs-csi-driver-trust-policy.json" ${PROFILE_STRING}

aws iam wait role-exists --role-name ${EBS_ROLE_NAME} ${PROFILE_STRING} 
echo "${EBS_ROLE_NAME} role 생성완료"