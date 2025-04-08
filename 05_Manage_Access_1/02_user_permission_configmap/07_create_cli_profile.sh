#!/bin/bash

if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

PROFILE_NAME=eks-edu-profile-${IDE_NAME}
# ==================================================================

aws configure --profile ${PROFILE_NAME}