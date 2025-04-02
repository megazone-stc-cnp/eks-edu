#!/bin/bash
if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh
# export AWS_REGION=ap-northeast-1
# export IDE_NAME=9641173
# export PROFILE_NAME=cnp-key
# export AWS_REPO_ACCOUNT=539666729110
# export HOME_DIR=/Users/mzc01-hcseo/00_PARA/01_project/autoever-eks-edu/source/eks-edu
# export EKS_VERSION=1.31
# export CLUSTER_NAME=eks-edu-cluster-${IDE_NAME}

POD_EXECUTION_ROLE_NAME=eks-edu-fargate-execution-role-${IDE_NAME}
# ============================================================================
echo "aws iam create-role \\
    --role-name ${POD_EXECUTION_ROLE_NAME} \\
    --assume-role-policy-document file://"tmp/fargate-profile-trust-relationship.json" \\
    --query Role.Arn --output text ${PROFILE_STRING}"

aws iam create-role \
    --role-name ${POD_EXECUTION_ROLE_NAME} \
    --assume-role-policy-document file://"tmp/fargate-profile-trust-relationship.json" \
    --query Role.Arn --output text ${PROFILE_STRING}