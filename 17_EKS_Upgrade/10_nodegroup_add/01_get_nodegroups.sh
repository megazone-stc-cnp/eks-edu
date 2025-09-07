#!/bin/bash

if [ ! -f "../../env.sh" ];then
  echo "env.sh 파일 세팅을 해주세요."
  exit 1
fi
. ../../env.sh

# ==================================================================
echo "aws eks list-nodegroups --cluster-name ${EKS_CLUSTER_NAME} --profile ${PROFILE_NAME} --region ${REGION_NAME} | jq -r '.nodegroups[]'"

NODEGROUP_LIST=$(aws eks list-nodegroups --cluster-name ${EKS_CLUSTER_NAME} --profile ${PROFILE_NAME} --region ${REGION_NAME} | jq -r '.nodegroups[]')

while IFS= read -r nodegroup_name; do
echo "======================================================"
echo "${nodegroup_name}"
aws eks describe-nodegroup \
    --cluster-name ${EKS_CLUSTER_NAME} \
    --nodegroup-name ${nodegroup_name} \
    --profile ${PROFILE_NAME} --region ${REGION_NAME} | jq '.nodegroup | {nodegroupName, scalingConfig, subnets, amiType, nodeRole, labels, launchTemplate, tags}'
done <<< "$NODEGROUP_LIST"    