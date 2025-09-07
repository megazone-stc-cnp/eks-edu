#!/bin/bash

if [ -z "$1" ];then
    echo "사용법: $0 <ADDON_VERSION>"
    exit 1
fi
ADDON_VERSION=$1

if [ ! -f "../../env.sh" ];then
  echo "env.sh 파일 세팅을 해주세요."
  exit 1
fi
. ../../env.sh

ADDON_NAME=coredns
# ==================================================================

echo aws eks update-addon --cluster-name ${EKS_CLUSTER_NAME} --addon-name ${ADDON_NAME} --addon-version ${ADDON_VERSION} --resolve-conflicts PRESERVE --region ${AWS_REGION} ${PROFILE_STRING}
aws eks update-addon \
    --cluster-name ${EKS_CLUSTER_NAME} \
    --addon-name ${ADDON_NAME} \
    --addon-version ${ADDON_VERSION} \
    --resolve-conflicts PRESERVE \
    --region ${AWS_REGION} ${PROFILE_STRING}
    # --service-account-role-arn arn:aws:iam::111122223333:role/eksctl-my-eks-cluster-addon-vpc-cni-Role1-YfakrqOC1UTm \
    # --configuration-values '{"resources": {"limits":{"cpu":"100m"}, "requests":{"cpu":"50m"}}}' \

echo "INFO: ${ADDON_NAME} Addon Complete check in aws management console !!!"