#!/bin/bash

if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

ARGOCD_CAPABILITY_ROLE_NAME=eks-edu-argocd-capability-role-${IDE_NAME}
CAPABILITY_NAME=argocd-${IDE_NAME}
# ==============================================================
echo "aws eks describe-capability \\
  --region ${AWS_REGION} \\
  --cluster-name ${CLUSTER_NAME} \\
  --capability-name ${CAPABILITY_NAME} \\
  --query 'capability.status' \\
  --output text ${PROFILE_STRING}"

aws eks describe-capability \
  --region ${AWS_REGION} \
  --cluster-name ${CLUSTER_NAME} \
  --capability-name ${CAPABILITY_NAME} \
  --query 'capability.status' \
  --output text ${PROFILE_STRING}