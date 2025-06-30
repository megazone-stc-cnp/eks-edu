#!/bin/bash

if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh

INSTANCE_TYPE=t3.large
# ==================================================================

echo "aws cloudformation create-stack \\
  --stack-name eks-workshop-${IDE_NAME} \\
  --template-body file://../00_Setup/eks-workshop-vscode-cfn.yaml \\
  --parameters ParameterKey=InstanceType,ParameterValue=${INSTANCE_TYPE} \\
  --capabilities CAPABILITY_NAMED_IAM ${PROFILE_STRING}"

aws cloudformation create-stack \
  --stack-name eks-workshop-${IDE_NAME} \
  --template-body file://../00_Setup/eks-workshop-vscode-cfn.yaml \
  --parameters ParameterKey=CodeServerInstanceType,ParameterValue=${INSTANCE_TYPE} \
  --capabilities CAPABILITY_NAMED_IAM ${PROFILE_STRING}

echo "생성중....."
echo "aws cloudformation wait stack-create-complete \\
    --stack-name eks-workshop-${IDE_NAME} ${PROFILE_STRING}"

aws cloudformation wait stack-create-complete \
    --stack-name eks-workshop-${IDE_NAME} ${PROFILE_STRING}
echo "생성완료....."    