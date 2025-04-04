#!/bin/bash
if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

if [ ! -f "../../vpc_env.sh" ];then
	echo "01_create_vpc 를 진행해 주세요."
	exit 1
fi
. ../../vpc_env.sh

EFS_SG_NAME=eks-edu-efs-sg-${IDE_NAME}
EFS_ID_NAME=eks-edu-efs-id-${IDE_NAME}
# ====================================================================
if [ ! -d "tmp" ]; then
    mkdir -p tmp
fi

# Create security group for EFS
echo "Creating security group for EFS..."
echo "aws ec2 create-security-group \\
    --group-name ${EFS_SG_NAME} \\
    --description \"Security group for EFS in EKS\" \\
    --vpc-id ${VPC_ID} \\
    --query \"GroupId\" \\
    --output text ${PROFILE_STRING}"

EFS_SG_ID=$(aws ec2 create-security-group \
    --group-name ${EFS_SG_NAME} \
    --description "Security group for EFS in EKS" \
    --vpc-id ${VPC_ID} \
    --query "GroupId" \
    --output text ${PROFILE_STRING})

echo "Created security group: ${EFS_SG_ID}"

# Add inbound rule to allow NFS traffic from the VPC CIDR
echo "aws ec2 authorize-security-group-ingress \\
    --group-id ${EFS_SG_ID} \\
    --protocol tcp \\
    --port 2049 \\
    --cidr ${VPC_CIDR} ${PROFILE_STRING}"

aws ec2 authorize-security-group-ingress \
    --group-id ${EFS_SG_ID} \
    --protocol tcp \
    --port 2049 \
    --cidr ${VPC_CIDR} ${PROFILE_STRING}

echo "Added inbound rule to security group"

# Create EFS file system
echo "Creating EFS file system..."
echo "aws efs create-file-system \\
    --performance-mode generalPurpose \\
    --throughput-mode bursting \\
    --encrypted \\
    --tags Key=Name,Value=${EFS_ID_NAME} \\
    --query \"FileSystemId\" \\
    --output text ${PROFILE_STRING}"

EFS_ID=$(aws efs create-file-system \
    --performance-mode generalPurpose \
    --throughput-mode bursting \
    --encrypted \
    --tags Key=Name,Value=${EFS_ID_NAME} \
    --query "FileSystemId" \
    --output text ${PROFILE_STRING})

echo "Created EFS file system: ${EFS_ID}"

# Wait for the file system to become available
echo "Waiting for EFS file system to become available..."
echo "aws efs wait file-system-available \\
    --file-system-id ${EFS_ID} ${PROFILE_STRING}"

aws efs wait file-system-available \
    --file-system-id ${EFS_ID} ${PROFILE_STRING}

# Create mount targets in each subnet
echo "aws efs create-mount-target \\
    --file-system-id ${EFS_ID} \\
    --subnet-id ${AWS_PRIVATE_SUBNET1} \\
    --security-groups ${EFS_SG_ID} ${PROFILE_STRING}"

aws efs create-mount-target \
    --file-system-id ${EFS_ID} \
    --subnet-id ${AWS_PRIVATE_SUBNET1} \
    --security-groups ${EFS_SG_ID} ${PROFILE_STRING}

echo "aws efs create-mount-target \\
    --file-system-id ${EFS_ID} \\
    --subnet-id ${AWS_PRIVATE_SUBNET2} \\
    --security-groups ${EFS_SG_ID} ${PROFILE_STRING}"

aws efs create-mount-target \
    --file-system-id ${EFS_ID} \
    --subnet-id ${AWS_PRIVATE_SUBNET2} \
    --security-groups ${EFS_SG_ID} ${PROFILE_STRING}

echo "EFS ID 값을 기록하세요: ${EFS_ID}"
