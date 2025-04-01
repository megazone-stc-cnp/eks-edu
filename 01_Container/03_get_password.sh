#!/bin/bash
if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh

# ==================================================================

aws secretsmanager get-secret-value \
    --secret-id eks-workshop-${EMPLOY_ID}-password \
    --query SecretString --output text \
    --region ${AWS_REGION} ${PROFILE_STRING} | jq -r .password
