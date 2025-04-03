#!/bin/bash
if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh

POD_EXECUTION_ROLE_NAME=eks-edu-fargate-execution-role-${IDE_NAME}
# ============================================================================
echo "aws iam create-role \\
    --role-name ${POD_EXECUTION_ROLE_NAME} \\
    --assume-role-policy-document file://"tmp/fargate-profile-trust-relationship.json" \\
    --query Role.Arn --output text ${PROFILE_STRING}"

aws iam create-role \
    --role-name ${POD_EXECUTION_ROLE_NAME} \
    --assume-role-policy-document file://"tmp/fargate-profile-trust-relationship.json" \
    --query Role.Arn --output text ${PROFILE_STRING}