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

# EBS 볼륨 생성 파라미터 설정
VOLUME_TYPE="gp3"
VOLUME_SIZE="1"
VOLUME_NAME="eks-ebs-volume-${IDE_NAME}"
# ===================================================================
# AWS CLI를 사용하여 EBS 볼륨 생성
echo "aws ec2 create-volume \\
    --volume-type ${VOLUME_TYPE} \\
    --size ${VOLUME_SIZE} \\
    --availability-zone ${AWS_AZ1} \\
    --tag-specifications \"ResourceType=volume,Tags=[{Key=Name,Value=${VOLUME_NAME}},{Key=kubernetes.io/cluster/${CLUSTER_NAME},Value=owned}]\" \\
    --query \"VolumeId\" \\
    --output text ${PROFILE_STRING}"

echo "Creating EBS volume..."
VOLUME_ID=$(aws ec2 create-volume \
    --volume-type ${VOLUME_TYPE} \
    --size ${VOLUME_SIZE} \
    --availability-zone ${AWS_AZ1} \
    --tag-specifications "ResourceType=volume,Tags=[{Key=Name,Value=${VOLUME_NAME}},{Key=kubernetes.io/cluster/${CLUSTER_NAME},Value=owned}]" \
    --query "VolumeId" \
    --output text ${PROFILE_STRING})

if [ $? -eq 0 ]; then
    echo "EBS volume created successfully with ID: ${VOLUME_ID}"
    
    # 볼륨 상태 확인
    echo "Waiting for volume to become available..."
    aws ec2 wait volume-available --volume-ids ${VOLUME_ID} ${PROFILE_STRING}
    echo "Volume is now available and ready to use."

    if [ -f "./local_env.sh" ];then
        rm -rf local_env.sh
    fi
    echo "#!/bin/bash" >> local_env.sh
    echo "export VOLUME_ID=${VOLUME_ID}" >> local_env.sh

else
    echo "Failed to create EBS volume."
    exit 1
fi
