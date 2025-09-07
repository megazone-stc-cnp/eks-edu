#!/bin/bash

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <ADDON_VERSION> <ROLE_NAME>"
  exit 1
fi

ADDON_VERSION=$1
ROLE_NAME=$2

echo "ADDON_VERSION: ${ADDON_VERSION}"
echo "ROLE_NAME: ${ROLE_NAME}"

if [ ! -f "../../env.sh" ];then
  echo "env.sh 파일 세팅을 해주세요."
  exit 1
fi
. ../../env.sh

ADDON_NAME=aws-ebs-csi-driver
# ==================================================================
PROFILE_STRING=""
if [ -n "$PROFILE_NAME" ]; then
    PROFILE_STRING="--profile ${PROFILE_NAME}"
fi

echo aws eks update-addon --cluster-name ${CLUSTER_NAME} --addon-name ${ADDON_NAME} --addon-version ${ADDON_VERSION} --resolve-conflicts PRESERVE --region ${AWS_REGION} ${PROFILE_STRING}
aws eks update-addon \
    --cluster-name ${CLUSTER_NAME} \
    --addon-name ${ADDON_NAME} \
    --addon-version ${ADDON_VERSION} \
    --service-account-role-arn arn:aws:iam::${ACCOUNT_ID}:role/${ROLE_NAME} \
    --resolve-conflicts PRESERVE \
    --region ${AWS_REGION} ${PROFILE_STRING}
    # --service-account-role-arn arn:aws:iam::111122223333:role/eksctl-my-eks-cluster-addon-vpc-cni-Role1-YfakrqOC1UTm \
    # --configuration-values '{"resources": {"limits":{"cpu":"100m"}, "requests":{"cpu":"50m"}}}' \

echo "INFO: ${ADDON_NAME} Addon Complete check in aws management console !!!"