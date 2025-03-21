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

echo "eksctl create iamidentitymapping \\
  --cluster eks-edu-cluster-${EMPLOY_ID} \\
  --arn arn:aws:iam::${AWS_REPO_ACCOUNT}:user/eks-edu-user-${EMPLOY_ID} \\
  --group pod-read-only \\
  --username eks-edu-user-${EMPLOY_ID} \\
  --region=${AWS_REGION} ${PROFILE_STRING}"

eksctl create iamidentitymapping \
  --cluster eks-edu-cluster-${EMPLOY_ID} \
  --arn arn:aws:iam::${AWS_REPO_ACCOUNT}:user/eks-edu-user-${EMPLOY_ID} \
  --group pod-read-only \
  --username eks-edu-user-${EMPLOY_ID} \
  --region=${AWS_REGION} ${PROFILE_STRING}

