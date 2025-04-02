#!/bin/bash
if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh
# export AWS_REGION=ap-northeast-1
# export IDE_NAME=9641173
# export PROFILE_NAME=cnp-key
# export AWS_REPO_ACCOUNT=539666729110
# export HOME_DIR=/Users/mzc01-hcseo/00_PARA/01_project/autoever-eks-edu/source/eks-edu
# export EKS_VERSION=1.31

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

EFS_SG_NAME="eks-edu-efs-sg-${IDE_NAME}"
EFS_NAME="eks-edu-efs-${IDE_NAME}"
# =================================================================
# Load VPC information
if [ ! -f "./local_env.sh" ];then
	echo "local_env.sh 파일이 없습니다. 01_get_output.sh를 실행해주세요."
	exit 1
fi
. ./local_env.sh

# Create security group for EFS
echo "Creating security group for EFS..."
EFS_SG_ID=$(aws ec2 create-security-group \
    --group-name ${EFS_SG_NAME} \
    --description "Security group for EFS in EKS" \
    --vpc-id ${VPC_ID} ${PROFILE_STRING} \
    --output text --query 'GroupId')

echo "Created security group: ${EFS_SG_ID}"

# Add ingress rule to allow NFS traffic from the VPC CIDR
VPC_CIDR=$(aws ec2 describe-vpcs --vpc-ids ${VPC_ID} \
    --query 'Vpcs[0].CidrBlock' --output text ${PROFILE_STRING})

aws ec2 authorize-security-group-ingress \
    --group-id ${EFS_SG_ID} \
    --protocol tcp \
    --port 2049 \
    --cidr ${VPC_CIDR} ${PROFILE_STRING}

echo "Added ingress rule to allow NFS traffic from ${VPC_CIDR}"

# Create EFS file system
echo "Creating EFS file system..."


EFS_FILE_SYSTEM_ID=$(aws efs create-file-system \
    --performance-mode generalPurpose \
    --throughput-mode bursting ${PROFILE_STRING} \
    --tags Key=Name,Value=${EFS_NAME} \
    --output text --query 'FileSystemId')

echo "Created EFS file system: ${EFS_FILE_SYSTEM_ID}"

# Wait for EFS to become available
echo "Waiting for EFS file system to become available..."
sleep 10

# Create mount targets in each private subnet
echo "Creating mount targets in private subnets..."
aws efs create-mount-target \
    --file-system-id ${EFS_FILE_SYSTEM_ID} \
    --subnet-id ${AWS_PRIVATE_SUBNET1} \
    --security-groups ${EFS_SG_ID} ${PROFILE_STRING}

aws efs create-mount-target \
    --file-system-id ${EFS_FILE_SYSTEM_ID} \
    --subnet-id ${AWS_PRIVATE_SUBNET2} \
    --security-groups ${EFS_SG_ID} ${PROFILE_STRING}

echo "Created mount targets in private subnets"

# Save EFS file system ID to a file for later use
echo "export EFS_FILE_SYSTEM_ID=${EFS_FILE_SYSTEM_ID}" >> local_env.sh

echo "EFS file system setup complete. File system ID: ${EFS_FILE_SYSTEM_ID}"

echo "[TODO] EKS Cluster SG에서 ${EFS_SG_NAME}으로 2049 포트가 열려있어야 합니다."