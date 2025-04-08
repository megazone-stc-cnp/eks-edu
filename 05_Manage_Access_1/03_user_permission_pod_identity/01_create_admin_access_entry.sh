#!/bin/bash

if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh

# ==================================================================

USER_NAME=eks-edu-user-${IDE_NAME}
POLICY_TYPE=AmazonEKSClusterAdminPolicy
#POLICY_TYPE=AmazonEKSAdminViewPolicy
echo "aws eks create-access-entry \\
    --cluster-name ${CLUSTER_NAME} \\
    --principal-arn arn:aws:iam::${AWS_ACCOUNT_ID}:user/${USER_NAME} \\
    --type STANDARD \\
    --username ${USER_NAME} ${PROFILE_STRING}"

aws eks create-access-entry \
    --cluster-name ${CLUSTER_NAME} \
    --principal-arn arn:aws:iam::${AWS_ACCOUNT_ID}:user/${USER_NAME} \
    --type STANDARD \
    --username ${USER_NAME} ${PROFILE_STRING}

echo "aws eks associate-access-policy \\
    --cluster-name ${CLUSTER_NAME} \\
    --principal-arn arn:aws:iam::${AWS_ACCOUNT_ID}:user/${USER_NAME} \\
    --access-scope type=cluster \\
    --policy-arn arn:aws:eks::aws:cluster-access-policy/${POLICY_TYPE} ${PROFILE_STRING}"

aws eks associate-access-policy \
    --cluster-name ${CLUSTER_NAME} \
    --principal-arn arn:aws:iam::${AWS_ACCOUNT_ID}:user/${USER_NAME} \
    --access-scope type=cluster \
    --policy-arn arn:aws:eks::aws:cluster-access-policy/${POLICY_TYPE} ${PROFILE_STRING}