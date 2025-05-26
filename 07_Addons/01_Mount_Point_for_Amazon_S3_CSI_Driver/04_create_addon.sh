#!/bin/bash

if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

ADDON_NAME=aws-mountpoint-s3-csi-driver
ROLE_NAME="mount-point-for-amazon-role-${IDE_NAME}"
# ==================================================================

eksctl create addon \
  --name ${ADDON_NAME} \
  --cluster $CLUSTER_NAME \
  --service-account-role-arn arn:aws:iam::${AWS_ACCOUNT_ID}:role/${ROLE_NAME} \
  --force ${PROFILE_STRING}