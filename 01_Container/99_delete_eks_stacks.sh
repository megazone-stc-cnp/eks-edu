#!/bin/bash
if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh

# ==================================================================

# 삭제 대상 prefix 목록
PREFIXES=("eks-" "eksctl-")

# 현재 리전에 있는 모든 스택 목록 가져오기
STACKS=$(aws cloudformation list-stacks \
  --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE ROLLBACK_COMPLETE UPDATE_ROLLBACK_COMPLETE \
  --query "StackSummaries[].StackName" --output text --region ${AWS_REGION} ${PROFILE_STRING})

# 삭제 대상 스택 찾기
for stack in $STACKS; do
  for prefix in "${PREFIXES[@]}"; do
    if [[ "$stack" == $prefix* ]]; then
      echo "Deleting stack: $stack"
      aws cloudformation delete-stack --stack-name "$stack" --region ${AWS_REGION} ${PROFILE_STRING}
    fi
  done
done