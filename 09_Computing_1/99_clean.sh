#!/bin/bash

if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh

POD_EXECUTION_ROLE_NAME=eks-edu-fargate-execution-role-${IDE_NAME}

aws iam detach-role-policy \
  --role-name ${POD_EXECUTION_ROLE_NAME} \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy \
  --no-cli-pager

aws iam delete-role \
    --role-name ${POD_EXECUTION_ROLE_NAME} \
    --no-cli-pager