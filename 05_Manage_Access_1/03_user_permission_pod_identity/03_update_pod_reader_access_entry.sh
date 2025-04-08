#!/bin/bash

if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh

# ==================================================================

USER_NAME=eks-edu-user-${IDE_NAME}
#POLICY_TYPE=AmazonEKSAdminViewPolicy
echo "aws eks update-access-entry \\
    --cluster-name ${CLUSTER_NAME} \\
    --principal-arn arn:aws:iam::${AWS_ACCOUNT_ID}:user/${USER_NAME} \\
    --kubernetes-groups pod-read-only ${PROFILE_STRING}"

aws eks update-access-entry \
    --cluster-name ${CLUSTER_NAME} \
    --principal-arn arn:aws:iam::${AWS_ACCOUNT_ID}:user/${USER_NAME} \
    --kubernetes-groups pod-read-only ${PROFILE_STRING}
