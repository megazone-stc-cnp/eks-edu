#!/bin/bash

if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

PROFILE_NAME=eks-edu-profile-${IDE_NAME}
# ==================================================================

echo "aws configure set region ${AWS_REGION} --profile ${PROFILE_NAME}"
echo "aws configure set output yaml --profile ${PROFILE_NAME}"
echo "aws configure set aws_access_key_id XXXXXXXXXX --profile ${PROFILE_NAME}"
echo "aws configure set aws_secret_access_key XXXXXXXXXXXXXXXXXXXX --profile ${PROFILE_NAME}"

aws configure set region ${AWS_REGION} --profile ${PROFILE_NAME}
aws configure set output json --profile ${PROFILE_NAME}
aws configure set aws_access_key_id "$(cat tmp/access_key.json | jq -r '.AccessKey.AccessKeyId')" --profile ${PROFILE_NAME}
aws configure set aws_secret_access_key "$(cat tmp/access_key.json | jq -r '.AccessKey.SecretAccessKey')" --profile ${PROFILE_NAME}

echo ""
echo "aws sts get-caller-identity --profile ${PROFILE_NAME}"
aws sts get-caller-identity --profile ${PROFILE_NAME}