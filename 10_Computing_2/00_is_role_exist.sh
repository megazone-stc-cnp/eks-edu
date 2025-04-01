#!/bin/bash
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

POD_EXECUTION_ROLE_NAME=eks-edu-fargate-execution-role-${EMPLOY_ID}
# ============================================================================
echo "aws iam get-role \\
  --role-name ${POD_EXECUTION_ROLE_NAME} ${PROFILE_STRING}"

if aws iam get-role --role-name ${POD_EXECUTION_ROLE_NAME} ${PROFILE_STRING} >/dev/null 2>&1; then
    echo "IAM Role '$POD_EXECUTION_ROLE_NAME' exists."
else
    echo "IAM Role '$POD_EXECUTION_ROLE_NAME' does not exists."
fi