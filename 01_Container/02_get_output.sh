#!/bin/bash
if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh

# ==================================================================

aws cloudformation describe-stacks \
    --stack-name eks-workshop-${EMPLOY_ID} --query "Stacks[0].Outputs" \
    --region ${AWS_REGION} ${PROFILE_STRING} --output json | tee result.json

cat result.json