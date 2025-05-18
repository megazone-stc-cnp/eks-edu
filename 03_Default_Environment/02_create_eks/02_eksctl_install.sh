#!/bin/bash

if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

# ==================================================================

echo "eksctl create cluster -f template/eksctl.yaml ${PROFILE_STRING}" 

eksctl create cluster -f template/eksctl.yaml ${PROFILE_STRING}

# EKS Cluster SG 추가
VPC_ENV_FILE_PATH=../../vpc_env.sh
cat >> ${VPC_ENV_FILE_PATH} << EOF
export EKS_CLUSTER_SG=$(aws eks describe-cluster --name $CLUSTER_NAME --no-cli-pager --query 'cluster.resourcesVpcConfig.clusterSecurityGroupId' --output text)
EOF