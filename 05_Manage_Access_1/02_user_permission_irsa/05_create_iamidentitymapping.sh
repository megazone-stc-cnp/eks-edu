#!/bin/bash

if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

IAM_USER=eks-edu-user-${IDE_NAME}
# ==================================================================

echo "eksctl create iamidentitymapping \\
  --cluster eks-edu-cluster-${IDE_NAME} \\
  --arn arn:aws:iam::${AWS_ACCOUNT_ID}:user/${IAM_USER} \\
  --group pod-read-only \\
  --username ${IAM_USER} ${PROFILE_STRING}"

eksctl create iamidentitymapping \
  --cluster eks-edu-cluster-${IDE_NAME} \
  --arn arn:aws:iam::${AWS_ACCOUNT_ID}:user/${IAM_USER} \
  --group pod-read-only \
  --username ${IAM_USER} ${PROFILE_STRING}

