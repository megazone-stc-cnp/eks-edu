#!/bin/bash

if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh

# ==================================================================

# User의 Access Key 생성
echo "aws iam create-access-key \
    --user-name eks-user-${IDE_NAME} ${PROFILE_STRING}"

aws iam create-access-key \
    --user-name eks-edu-user-${IDE_NAME} ${PROFILE_STRING}
    
echo "Access Key와 Secret Key는 사용하기 때문에 기록을 해야 한다.