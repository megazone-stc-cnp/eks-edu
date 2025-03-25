#!/bin/bash
if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh
# export AWS_REGION=ap-northeast-1
# export EMPLOY_ID=9641173
# export PROFILE_NAME=cnp-key
# export AWS_REPO_ACCOUNT=539666729110
# export HOME_DIR=/Users/mzc01-hcseo/00_PARA/01_project/autoever-eks-edu/source/eks-edu
# export EKS_VERSION=1.31
# export CLUSTER_NAME=eks-edu-cluster-${EMPLOY_ID}

if [ ! -f "./local_env.sh" ];then
	echo "local_env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ./local_env.sh
# export VPC_ID=vpc-045741095e8efe028
# export AWS_AZ1=ap-northeast-1a
# export AWS_AZ2=ap-northeast-1c
# export AWS_PRIVATE_SUBNET1=subnet-01b7dce75dc1b79e5
# export AWS_PRIVATE_SUBNET2=subnet-0cf18e5c66c385020
# export EKS_ADDITIONAL_SG=sg-03290c4da8c08c351

# ==================================================================
echo "aws eks describe-cluster \\
            --name ${CLUSTER_NAME} \\
            --query cluster.resourcesVpcConfig.clusterSecurityGroupId \\
            --output text \\
            --region ${AWS_REGION} ${PROFILE_STRING}"

cluster_security_group_id=$(
        aws eks describe-cluster \
            --name ${CLUSTER_NAME} \
            --query cluster.resourcesVpcConfig.clusterSecurityGroupId \
            --output text \
            --region ${AWS_REGION} ${PROFILE_STRING}
)

echo "EKS Cluster SG: ${cluster_security_group_id}"

echo "export EKS_CLUSTER_SG=${cluster_security_group_id}" >> local_env.sh