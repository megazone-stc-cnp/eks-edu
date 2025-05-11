#!/usr/bin/env bash
if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh

envsubst < pod-execution-role-trust-policy.json > pod-execution-role-trust-policy.json.tmp

POD_EXECUTION_ROLE_NAME=eks-edu-fargate-execution-role-${IDE_NAME}
# ============================================================================
echo "aws iam create-role \\
    --role-name ${POD_EXECUTION_ROLE_NAME} \\
    --assume-role-policy-document file://pod-execution-role-trust-policy.json.tmp \\
    --query Role.Arn --output text"

aws iam create-role \
    --role-name ${POD_EXECUTION_ROLE_NAME} \
    --assume-role-policy-document file://pod-execution-role-trust-policy.json.tmp \
    --query Role.Arn --output text --no-cli-pager

aws iam attach-role-policy \
  --role-name ${POD_EXECUTION_ROLE_NAME} \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy \
  --no-cli-pager