#!/bin/bash
if [ ! -f "../.env" ];then
	echo ".env 파일 세팅을 해주세요."
	exit 1
fi
. ../.env

# ==================================================================
PROFILE_STRING=""
if [ -n "$PROFILE_NAME" ]; then
    PROFILE_STRING="--profile ${PROFILE_NAME}"
fi

aws cloudformation describe-stacks \
    --stack-name eks-edu-${EMPLOY_ID} --query "Stacks[0].Outputs" \
    --region ${AWS_REGION} ${PROFILE_STRING}