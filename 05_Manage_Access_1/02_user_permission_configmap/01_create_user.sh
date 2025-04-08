#!/bin/bash

if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

IAM_USER=eks-edu-user-${IDE_NAME}
# ==================================================================
# Check if IAM user already exists
if aws iam get-user --user-name eks-edu-user-${IDE_NAME} ${PROFILE_STRING} >/dev/null 2>&1; then
    echo "User eks-edu-user-${IDE_NAME} 가 존재합니다."
    exit 1
fi

# IAM User 생성
echo "aws iam create-user \\
    --user-name ${IAM_USER} ${PROFILE_STRING}"

echo "${IAM_USER} User 생성중..."

aws iam create-user \
    --user-name ${IAM_USER} ${PROFILE_STRING}

aws iam wait user-exists \
    --user-name ${IAM_USER} ${PROFILE_STRING}

echo "${IAM_USER} User 생성 완료..."