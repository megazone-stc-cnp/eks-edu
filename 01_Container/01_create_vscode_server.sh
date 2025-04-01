#!/bin/bash

if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh

# ==================================================================

echo "aws cloudformation create-stack \\
  --stack-name eks-workshop-${EMPLOY_ID} \\
  --template-body file://eks-workshop-vscode-cfn.yaml \\
  --capabilities CAPABILITY_NAMED_IAM \\
  --region ${AWS_REGION} ${PROFILE_STRING}"
  
aws cloudformation create-stack \
  --stack-name eks-workshop-${EMPLOY_ID} \
  --template-body file://eks-workshop-vscode-cfn.yaml \
  --capabilities CAPABILITY_NAMED_IAM \
  --region ${AWS_REGION} ${PROFILE_STRING}

echo "생성중....."
echo "aws cloudformation wait stack-create-complete \\
    --stack-name eks-workshop-${EMPLOY_ID} \\
    --region ${AWS_REGION} ${PROFILE_STRING}"

aws cloudformation wait stack-create-complete \
    --stack-name eks-workshop-${EMPLOY_ID} \
    --region ${AWS_REGION} ${PROFILE_STRING}
echo "생성완료....."    