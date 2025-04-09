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

EFS_ROLE_NAME=eks-edu-efs-pod-identity-role-${IDE_NAME}
# ===============================================

echo "aws iam attach-role-policy \\
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy \\
  --role-name ${EFS_ROLE_NAME} ${PROFILE_STRING}"

aws iam attach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy \
  --role-name ${EFS_ROLE_NAME} ${PROFILE_STRING}