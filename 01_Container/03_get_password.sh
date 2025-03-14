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

aws secretsmanager get-secret-value \
    --secret-id eks-edu-9641173-password \
    --query SecretString --output text \
    --region ${AWS_REGION} ${PROFILE_STRING} | jq -r .password
