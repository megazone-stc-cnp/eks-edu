#!/bin/bash

if [ -z "$1" ]; then
    echo "사용법: $0 <GOLDEN_IMAGE_ID>"
    exit 1
fi
GOLDEN_IMAGE_ID=$1

if [ ! -f "../../env.sh" ];then
  echo "env.sh 파일 세팅을 해주세요."
  exit 1
fi
. ../../env.sh

# ==============================================================
echo "aws ec2 describe-images \\
    --image-ids ${GOLDEN_IMAGE_ID} \\
    --region ${AWS_REGION} ${PROFILE_STRING} \\
    --output json"

aws ec2 describe-images \
    --image-ids ${GOLDEN_IMAGE_ID} \
    --region ${AWS_REGION} ${PROFILE_STRING} \
    --output json


