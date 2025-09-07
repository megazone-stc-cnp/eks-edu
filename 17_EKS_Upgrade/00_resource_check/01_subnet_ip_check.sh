#!/bin/bash

if [ ! -f "../../env.sh" ];then
  echo "env.sh 파일 세팅을 해주세요."
  exit 1
fi
. ../../env.sh

# ==============================================================
aws ec2 describe-subnets --subnet-ids \
  $(aws eks describe-cluster --name ${EKS_CLUSTER_NAME} \
  --query 'cluster.resourcesVpcConfig.subnetIds' \
  --output text \
  --region ${AWS_REGION} ${PROFILE_STRING}) \
  --query 'Subnets[*].[SubnetId,AvailabilityZone,AvailableIpAddressCount]' \
  --output table \
  --region ${AWS_REGION} ${PROFILE_STRING}
