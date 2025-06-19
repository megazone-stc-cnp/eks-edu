#!/bin/bash

if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh
POLICY_NAME=eks-edu-cluster-${IDE_NAME}-addon-aws-lbc-iam-pol
# ==================================================================

echo "aws iam delete-policy --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${POLICY_NAME}"
echo ""

aws iam delete-policy --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${POLICY_NAME}