#!/bin/bash

if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

STACK_NAME=eks-workshop-vpc-${EMPLOY_ID}
# ==================================================================
# Check if the stack already exists
echo "스택 존재 여부 확인 중....."
if aws cloudformation describe-stacks --stack-name ${STACK_NAME} --region ${AWS_REGION} ${PROFILE_STRING} &> /dev/null; then
    echo "${STACK_NAME} 스택이 이미 존재합니다."
    exit 1
fi

echo "aws cloudformation create-stack \\
  --stack-name ${STACK_NAME} \\
  --template-body file://amazon-eks-vpc-private-subnets.yaml \\
  --capabilities CAPABILITY_NAMED_IAM \\
  --region ${AWS_REGION} ${PROFILE_STRING}"

echo "기본 VPC 생성중....."
aws cloudformation create-stack \
  --stack-name ${STACK_NAME} \
  --template-body file://amazon-eks-vpc-private-subnets.yaml \
  --capabilities CAPABILITY_NAMED_IAM \
  --region ${AWS_REGION} ${PROFILE_STRING}

aws cloudformation wait stack-create-complete \
    --stack-name ${STACK_NAME} \
    --region ${AWS_REGION} ${PROFILE_STRING}
echo "기본 VPC 생성완료....."