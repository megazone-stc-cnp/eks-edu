#!/bin/bash

if [ ! -f "../../env.sh" ];then
  echo "env.sh 파일 세팅을 해주세요."
  exit 1
fi
. ../../env.sh

ADDON_NAME=aws-ebs-csi-driver
# ================================
echo aws eks describe-addon --cluster-name ${CLUSTER_NAME} --addon-name ${ADDON_NAME} ${PROFILE_STRING} --region ${AWS_REGION}
aws eks describe-addon \
    --cluster-name ${CLUSTER_NAME} \
    --addon-name ${ADDON_NAME} \
    --region ${AWS_REGION} ${PROFILE_STRING}
