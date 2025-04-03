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

EBS_ROLE_NAME=eks-edu-ebs-irsa-role-${IDE_NAME}
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