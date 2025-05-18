#!/bin/bash
if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

if [ ! -f "../../vpc_env.sh" ];then
	echo "vpc_env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../vpc_env.sh

# ALB 이름 설정
ALB_NAME="eks-edu-alb-${IDE_NAME}"
SG_NAME="eks-edu-alb-sg-${IDE_NAME}"
# ==============================================================
# ALB에 붙일 Security Group 생성
echo "Creating Security Group for ALB: ${SG_NAME}"

SG_ID=$(aws ec2 create-security-group \
    --group-name ${SG_NAME} \
    --description "Security group for ALB:${ALB_NAME}" \
    --vpc-id ${VPC_ID} ${PROFILE_STRING} \
    --query 'GroupId' \
    --output text)

if [ -z "$SG_ID" ]; then
    echo "Security Group 생성에 실패했습니다."
    exit 1
fi

echo "Security Group이 성공적으로 생성되었습니다. ID: ${SG_ID}"

# HTTP 트래픽 허용 규칙 추가
echo "Adding ingress rule for HTTP traffic"
aws ec2 authorize-security-group-ingress \
    --group-id ${SG_ID} \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0 ${PROFILE_STRING}

echo "Security Group 설정이 완료되었습니다."
echo "[TODO] EKS Cluster Security Group의 Inbound에 이 Security Group을 등록해야 한다 ( Port: 80 )."
echo "export ALB_SECURITY_GROUP_ID=${SG_ID}" > ./local_env.sh
echo "" >> ./local_env.sh
