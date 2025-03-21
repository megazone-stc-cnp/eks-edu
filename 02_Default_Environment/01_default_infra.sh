#!/bin/bash

if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh

# ==================================================================
PROFILE_STRING=""
if [ -n "$PROFILE_NAME" ]; then
    PROFILE_STRING="--profile ${PROFILE_NAME}"
fi
STACK_NAME=eks-workshop-vpc-${EMPLOY_ID}
echo "aws cloudformation create-stack \\
  --stack-name ${STACK_NAME} \\
  --template-body file://amazon-eks-vpc-private-subnets.yaml \\
  --capabilities CAPABILITY_NAMED_IAM \\
  --region ${AWS_REGION} ${PROFILE_STRING}"

aws cloudformation create-stack \
  --stack-name ${STACK_NAME} \
  --template-body file://amazon-eks-vpc-private-subnets.yaml \
  --capabilities CAPABILITY_NAMED_IAM \
  --region ${AWS_REGION} ${PROFILE_STRING}

echo "생성중....."
echo "aws cloudformation wait stack-create-complete \\
    --stack-name ${STACK_NAME} \\
    --region ${AWS_REGION} ${PROFILE_STRING}"

aws cloudformation wait stack-create-complete \
    --stack-name ${STACK_NAME} \
    --region ${AWS_REGION} ${PROFILE_STRING}
    
echo "생성완료....."    