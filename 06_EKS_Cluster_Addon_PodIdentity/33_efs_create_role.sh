#!/bin/bash
#
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
POLICY_FILENAME=aws-efs-csi-driver-pod-identity-trust-policy.json
EFS_ROLE_NAME=eks-edu-efs-pod-identity-role-${EMPLOY_ID}
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