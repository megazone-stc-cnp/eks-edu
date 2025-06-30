#!/usr/bin/env bash

if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
source ../env.sh

# AWS CLI 실행을 위한 환경변수 설정
export ADDON_NAME="aws-lbc"
export ADDON_VERSION="v2.13.2"
export ADDON_IAM_POLICY_NAME=${CLUSTER_NAME}-addon-${ADDON_NAME}-iam-pol
export ADDON_IAM_ROLE_NAME=${CLUSTER_NAME}-addon-${ADDON_NAME}-iam-rol
export IRSA_NAME=aws-lbc-sa


# ==================================================================
POLICY_ARN=arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${ADDON_IAM_POLICY_NAME}

# AWS LBC 용 IAM Policy 다운로드
curl -o aws-lbc-iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/${ADDON_VERSION}/docs/install/iam_policy.json

POLICY_EXISTS=$(aws iam get-policy --policy-arn ${POLICY_ARN} 2>&1 || echo "POLICY_NOT_FOUND")
if [[ ! "$POLICY_EXISTS" == *"POLICY_NOT_FOUND"* ]]; then
  # 정책 삭제
  echo "aws iam delete-policy --policy-arn ${POLICY_ARN}"
  aws iam delete-policy --policy-arn ${POLICY_ARN}
else
  echo "${POLICY_NAME}이 존재하지 않습니다."
fi

# IAM Policy 생성
export ADDON_IAM_POLICY_ARN=$(aws iam create-policy --policy-name ${ADDON_IAM_POLICY_NAME} --policy-document file://aws-lbc-iam-policy.json --output text --no-cli-pager --query "Policy.Arn")

# IAM Role 생성 (eksctl 사용)
eksctl create iamserviceaccount \
    --cluster=${CLUSTER_NAME} \
    --namespace=kube-system \
    --name=${IRSA_NAME} \
    --role-name=${ADDON_IAM_ROLE_NAME} \
    --attach-policy-arn=${ADDON_IAM_POLICY_ARN} \
    --override-existing-serviceaccounts \
    --region $AWS_REGION \
    --approve