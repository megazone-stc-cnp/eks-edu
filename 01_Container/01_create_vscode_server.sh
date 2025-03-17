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

aws cloudformation create-stack \
  --stack-name eks-edu-${EMPLOY_ID} \
  --template-body file://eks-workshop-vscode-cfn.yaml \
  --capabilities CAPABILITY_NAMED_IAM \
  --region ${AWS_REGION} ${PROFILE_STRING}

echo "생성중....."
aws cloudformation wait stack-create-complete \
    --stack-name eks-edu-${EMPLOY_ID}
echo "생성완료....."    