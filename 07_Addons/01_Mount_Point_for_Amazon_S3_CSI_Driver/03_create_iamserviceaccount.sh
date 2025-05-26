#!/bin/bash

if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

SERVICE_NAME=s3-csi-driver-sa
NAMESPACE_NAME=kube-system
POLICY_NAME="mount-point-for-amazon-policy-${IDE_NAME}"
ROLE_NAME="mount-point-for-amazon-role-${IDE_NAME}"
# ==================================================================
eksctl create iamserviceaccount \
  --name ${SERVICE_NAME} \
  --namespace ${NAMESPACE_NAME} \
  --cluster ${CLUSTER_NAME} \
  --attach-policy-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${POLICY_NAME}" \
  --approve \
  --role-name ${ROLE_NAME} \
  --region ${AWS_REGION} \
  --role-only