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
# export CLUSTER_NAME=eks-edu-cluster-${IDE_NAME}

if [ ! -f "./local_env.sh" ];then
	echo "local_env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ./local_env.sh
# export VPC_ID=vpc-0264324861f559add
# export AWS_AZ1=ap-northeast-1a
# export AWS_AZ2=ap-northeast-1c
# export AWS_PRIVATE_SUBNET1=subnet-06a6dc4043dc1e5b6
# export AWS_PRIVATE_SUBNET2=subnet-0dadf6ad0b509415f
# export EKS_ADDITIONAL_SG=sg-0a5e29c6c67f89643
# export AWS_PUBLIC_SUBNET1=subnet-059cb0b98cd7850b9
# export AWS_PUBLIC_SUBNET2=subnet-0b12d717922b90cc2

# NLB 이름 설정
SG_NAME="eks-edu-alb-sg-${IDE_NAME}"
# ==============================================================
# NLB에 붙일 Security Group 생성
echo "Creating Security Group for ALB: ${SG_NAME}"

SG_ID=$(aws ec2 create-security-group \
    --group-name ${SG_NAME} \
    --description "Security group for ALB ${NLB_NAME}" \
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
echo "[TODO] EKS Cluster Security Group의 Inbound에 이 Security Group을 등록해야 한다 ( Port: 80 ). 
echo "export ALB_SECURITY_GROUP_ID=${SG_ID}" >> local_env.sh
echo "" >> local_env.sh