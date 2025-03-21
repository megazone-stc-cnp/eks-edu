#!/bin/bash

if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh

CLUSTER_NAME=eks-edu-cluster-${EMPLOY_ID}
# ==================================================================
PROFILE_STRING=""
if [ -n "$PROFILE_NAME" ]; then
    PROFILE_STRING="--profile ${PROFILE_NAME}"
fi

USER_NAME=eks-edu-user-${EMPLOY_ID}
#POLICY_TYPE=AmazonEKSAdminViewPolicy
echo "aws eks update-access-entry \\
    --cluster-name ${CLUSTER_NAME} \\
    --principal-arn arn:aws:iam::${AWS_REPO_ACCOUNT}:user/${USER_NAME} \\
    --kubernetes-groups pod-read-only \\
    --region ${AWS_REGION} ${PROFILE_STRING}"

aws eks update-access-entry \
    --cluster-name ${CLUSTER_NAME} \
    --principal-arn arn:aws:iam::${AWS_REPO_ACCOUNT}:user/${USER_NAME} \
    --kubernetes-groups pod-read-only \
    --region ${AWS_REGION} ${PROFILE_STRING}
