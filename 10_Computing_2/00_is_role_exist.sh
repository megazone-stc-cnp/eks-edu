#!/bin/bash
if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh

POD_EXECUTION_ROLE_NAME=eks-edu-fargate-execution-role-${IDE_NAME}
# ============================================================================
echo "aws iam get-role \\
  --role-name ${POD_EXECUTION_ROLE_NAME} ${PROFILE_STRING}"

if aws iam get-role --role-name ${POD_EXECUTION_ROLE_NAME} ${PROFILE_STRING} >/dev/null 2>&1; then
    echo "IAM Role '$POD_EXECUTION_ROLE_NAME' exists."
else
    echo "IAM Role '$POD_EXECUTION_ROLE_NAME' does not exists."
fi