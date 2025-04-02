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
# ==================================================================

USER_NAME=eks-edu-user-${IDE_NAME}
POLICY_TYPE=AmazonEKSClusterAdminPolicy
#POLICY_TYPE=AmazonEKSAdminViewPolicy
echo "aws eks create-access-entry \\
    --cluster-name ${CLUSTER_NAME} \\
    --principal-arn arn:aws:iam::${AWS_REPO_ACCOUNT}:user/${USER_NAME} \\
    --type STANDARD \\
    --username ${USER_NAME} ${PROFILE_STRING}"

aws eks create-access-entry \
    --cluster-name ${CLUSTER_NAME} \
    --principal-arn arn:aws:iam::${AWS_REPO_ACCOUNT}:user/${USER_NAME} \
    --type STANDARD \
    --username ${USER_NAME} ${PROFILE_STRING}

echo "aws eks associate-access-policy \\
    --cluster-name ${CLUSTER_NAME} \\
    --principal-arn arn:aws:iam::${AWS_REPO_ACCOUNT}:user/${USER_NAME} \\
    --access-scope type=cluster \\
    --policy-arn arn:aws:eks::aws:cluster-access-policy/${POLICY_TYPE} ${PROFILE_STRING}"

aws eks associate-access-policy \
    --cluster-name ${CLUSTER_NAME} \
    --principal-arn arn:aws:iam::${AWS_REPO_ACCOUNT}:user/${USER_NAME} \
    --access-scope type=cluster \
    --policy-arn arn:aws:eks::aws:cluster-access-policy/${POLICY_TYPE} ${PROFILE_STRING}