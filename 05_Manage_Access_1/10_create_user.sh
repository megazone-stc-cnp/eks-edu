#!/bin/bash

if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh

# ==================================================================

# IAM User 생성
echo "aws iam create-user \
    --user-name eks-edu-user-${IDE_NAME} ${PROFILE_STRING}"

aws iam create-user \
    --user-name eks-edu-user-${IDE_NAME} ${PROFILE_STRING}

