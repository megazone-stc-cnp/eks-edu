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

EFS_SECURITY_GROUP=$(aws ec2 create-security-group \
    --group-name ${EFS_SG_NAME} \
    --description "Security group for EFS in EKS" \
    --vpc-id ${VPC_ID} \
    --query "GroupId" \
    --output text ${PROFILE_STRING})

echo "Created security group: ${EFS_SECURITY_GROUP}"

# Add inbound rule to allow NFS traffic from the VPC CIDR
echo "aws ec2 authorize-security-group-ingress \\
    --group-id ${EFS_SECURITY_GROUP} \\
    --protocol tcp \\
    --port 2049 \\
    --cidr ${VPC_CIDR} ${PROFILE_STRING}"

aws ec2 authorize-security-group-ingress \
    --group-id ${EFS_SECURITY_GROUP} \
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

sleep 10

# Create mount targets in each subnet
echo "aws efs create-mount-target \\
    --file-system-id ${EFS_ID} \\
    --subnet-id ${AWS_PRIVATE_SUBNET1} \\
    --security-groups ${EFS_SECURITY_GROUP} ${PROFILE_STRING}"

aws efs create-mount-target \
    --file-system-id ${EFS_ID} \
    --subnet-id ${AWS_PRIVATE_SUBNET1} \
    --security-groups ${EFS_SECURITY_GROUP} ${PROFILE_STRING}

echo "aws efs create-mount-target \\
    --file-system-id ${EFS_ID} \\
    --subnet-id ${AWS_PRIVATE_SUBNET2} \\
    --security-groups ${EFS_SECURITY_GROUP} ${PROFILE_STRING}"

aws efs create-mount-target \
    --file-system-id ${EFS_ID} \
    --subnet-id ${AWS_PRIVATE_SUBNET2} \
    --security-groups ${EFS_SECURITY_GROUP} ${PROFILE_STRING}

if [ -f "./local_env.sh" ];then
    rm -rf local_env.sh
fi
echo "#!/bin/bash" >> local_env.sh
echo "export EFS_ID=${EFS_ID}" >> local_env.sh
echo "export EFS_SECURITY_GROUP=${EFS_SECURITY_GROUP}" >> local_env.sh
