#!/bin/bash

if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

BUCKET_NAME="pod-secrets-bucket-${IDE_NAME}"
POLICY_NAME=eks-edu-irsa-workload-policy-${IDE_NAME}
# ================================================
echo "aws iam delete-policy \\
        --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${POLICY_NAME} ${PROFILE_STRING}"
echo ""
aws iam delete-policy \
    --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${POLICY_NAME} ${PROFILE_STRING}

# Delete all objects in the bucket first
echo "aws s3 rm s3://${BUCKET_NAME} --recursive ${PROFILE_STRING}"
aws s3 rm s3://${BUCKET_NAME} --recursive ${PROFILE_STRING}

# Delete the bucket
echo "aws s3 rb s3://${BUCKET_NAME} ${PROFILE_STRING}"
aws s3 rb s3://${BUCKET_NAME} ${PROFILE_STRING}