#!/bin/bash
if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh

if [ ! -f "./local_env.sh" ];then
	echo "local_env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ./local_env.sh
# export VPC_ID=vpc-09effdadb2d737300
# export AWS_AZ1=ap-northeast-1a
# export AWS_AZ2=ap-northeast-1c
# export AWS_PRIVATE_SUBNET1=subnet-03ed17397746222a8
# export AWS_PRIVATE_SUBNET2=subnet-07873917f6e87880b
# export EKS_ADDITIONAL_SG=sg-033a4c5fa9437d100

NODE_NAME=eks-edu-app-node
INSTANCE_TYP=t3.medium
NODE_NUM=2
AMI_FAMAILY=AmazonLinux2023
# ==================================================================
echo "eksctl create nodegroup \\
  --cluster ${CLUSTER_NAME} \\
  --name ${NODE_NAME} \\
  --node-ami-family ${AMI_FAMAILY} \\
  --node-type ${INSTANCE_TYP} \\
  --nodes ${NODE_NUM} \\
  --nodes-min ${NODE_NUM} \\
  --nodes-max $((NODE_NUM * 2)) \\
  --enable-ssm \\
  --subnet-ids ${AWS_PRIVATE_SUBNET1},${AWS_PRIVATE_SUBNET2} \\
  --node-labels "role=app" \\
  --node-private-networking ${PROFILE_STRING}"

eksctl create nodegroup \
  --cluster ${CLUSTER_NAME} \
  --name ${NODE_NAME} \
  --node-ami-family ${AMI_FAMAILY} \
  --node-type ${INSTANCE_TYP} \
  --nodes ${NODE_NUM} \
  --nodes-min ${NODE_NUM} \
  --nodes-max $((NODE_NUM * 2)) \
  --enable-ssm \
  --subnet-ids ${AWS_PRIVATE_SUBNET1},${AWS_PRIVATE_SUBNET2} \
  --node-labels "role=app" \
  --node-private-networking ${PROFILE_STRING}
  
#   --ssh-access : 
# control SSH access for nodes. Uses ~/.ssh/id_rsa.pub as default key path if enabled
#   --ssh-public-key my-key : 
# SSH public key to use for nodes (import from local path, or use existing EC2 key pair) 
#   --node-security-groups strings : 
# attach additional security groups to nodes
#   --spot :
# Create a spot nodegroup (managed nodegroups only)