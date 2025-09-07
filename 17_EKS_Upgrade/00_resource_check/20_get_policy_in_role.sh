#!/bin/bash

if [ ! -f "../env.sh" ]; then
    echo "Error: ../env.sh 파일이 존재하지 않습니다."
    exit 1
fi

if [ -z "$1" ]; then
    echo "사용법: $0 <ROLE_NAME>"
    exit 1
fi
ROLE_NAME=$1

if [ ! -f "../../env.sh" ];then
  echo "env.sh 파일 세팅을 해주세요."
  exit 1
fi
. ../../env.sh

# ================================
# Role 이름에 해당하는 정보 조회
POLICY_ARN=$(aws iam list-attached-role-policies --role-name ${ROLE_NAME} --profile ${PROFILE_NAME} --query "AttachedPolicies[0].PolicyArn" --output json  2>/dev/null)

# Role이 존재하는지 확인
if [ -z "$POLICY_ARN" ]; then
  echo "해당 Role(${ROLE_NAME})을 찾을 수 없습니다."
  exit 1
fi

VERSION_ID=$(aws iam get-policy --policy-arn $(echo ${POLICY_ARN} | tr -d '"') --query "Policy.DefaultVersionId" --profile ${PROFILE_NAME})

aws iam get-policy-version --policy-arn $(echo ${POLICY_ARN} | tr -d '"') --version-id $(echo ${VERSION_ID} | tr -d '"') --profile ${PROFILE_NAME} --no-cli-pager
