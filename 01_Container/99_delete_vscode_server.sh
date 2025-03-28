#!/bin/bash
if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh

# ==================================================================

aws cloudformation delete-stack \
  --stack-name eks-workshop-${EMPLOY_ID} \
  --region ${AWS_REGION} ${PROFILE_STRING}

echo "삭제중....."
aws cloudformation wait stack-delete-complete \
    --stack-name eks-workshop-${EMPLOY_ID}
echo "삭제 완료....."    