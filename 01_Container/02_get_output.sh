#!/bin/bash
if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh

# ==================================================================

aws cloudformation describe-stacks \
    --stack-name eks-workshop-${IDE_NAME} --query "Stacks[0].Outputs" ${PROFILE_STRING} --output json | tee result.json

cat result.json