#!/bin/bash

if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

IAM_USER=eks-edu-user-${IDE_NAME}
# ==================================================================
if [ ! -d "tmp" ]; then
    mkdir -p tmp
fi

# User의 Access Key 생성
echo "aws iam create-access-key \\
    --user-name ${IAM_USER} ${PROFILE_STRING} --output json"

aws iam create-access-key \
    --user-name ${IAM_USER} ${PROFILE_STRING} --output json | tee tmp/access_key.json
    
echo "[TODO] Access Key와 Secret Key는 사용하기 때문에 기록을 해야 한다. (tmp/access_key.json 파일에 저장)