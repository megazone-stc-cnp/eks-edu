#!/bin/bash
#
if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh

POLICY_FILENAME=aws-efs-csi-driver-pod-identity-trust-policy.json
EFS_ROLE_NAME=eks-edu-efs-pod-identity-role-${IDE_NAME}
# ===============================================
echo "aws iam create-role \\
  --role-name ${EFS_ROLE_NAME} \\
  --assume-role-policy-document file://"${POLICY_FILENAME}" ${PROFILE_STRING}"

echo "${EFS_ROLE_NAME} role 생성중"
aws iam create-role \
  --role-name ${EFS_ROLE_NAME} \
  --assume-role-policy-document file://"${POLICY_FILENAME}" ${PROFILE_STRING}

aws iam wait role-exists --role-name ${EFS_ROLE_NAME} ${PROFILE_STRING} 
echo "${EFS_ROLE_NAME} role 생성완료"