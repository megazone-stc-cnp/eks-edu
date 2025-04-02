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

SERVICE_ACCOUNT_NAME=eks-edu-pod-identity-service-account-${IDE_NAME}
POLICY_NAME=eks-edu-pod-identity-workload-policy-${IDE_NAME}
ROLE_NAME=eks-edu-pod-identity-workload-role-${IDE_NAME}
NAMESPACE_NAME=default
# ==================================================================

echo "aws eks create-pod-identity-association \\
    --cluster-name ${CLUSTER_NAME} \\
    --role-arn arn:aws:iam::${AWS_REPO_ACCOUNT}:role/${ROLE_NAME} \\
    --namespace ${NAMESPACE_NAME} \\
    --service-account ${SERVICE_ACCOUNT_NAME} ${PROFILE_STRING}"

aws eks create-pod-identity-association \
    --cluster-name ${CLUSTER_NAME} \
    --role-arn arn:aws:iam::${AWS_REPO_ACCOUNT}:role/${ROLE_NAME} \
    --namespace ${NAMESPACE_NAME} \
    --service-account ${SERVICE_ACCOUNT_NAME} ${PROFILE_STRING}