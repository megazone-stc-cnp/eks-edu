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
# ==================================================================

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
