#!/bin/bash
if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

POLICY_NAME=eks-edu-aws-load-balancer-controller-policy-${IDE_NAME}
# ==================================================================

# Check if the policy already exists
POLICY_EXISTS=$(aws iam get-policy --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${POLICY_NAME} ${PROFILE_STRING} 2>&1 || echo "POLICY_NOT_FOUND")

if [[ ! "$POLICY_EXISTS" == *"POLICY_NOT_FOUND"* ]]; then
    echo "Error: ${POLICY_NAME} 이 존재합니다. 삭제를 진행하고 다시 진행해 주세요."
    exit 1
fi

echo "aws iam create-policy \\
    --policy-name ${POLICY_NAME} \\
    --policy-document file://tmp/iam_policy.json ${PROFILE_STRING}"

aws iam create-policy \
    --policy-name ${POLICY_NAME} \
    --policy-document file://tmp/iam_policy.json ${PROFILE_STRING}