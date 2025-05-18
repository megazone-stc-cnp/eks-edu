#!/usr/bin/env bash

cd ~/environment/eks-edu/11_Network_2
source ../env.sh

# AWS CLI 실행을 위한 환경변수 설정
export ADDON_NAME="aws-lbc"
export ADDON_VERSION="v2.13.2"
export OIDC_ID=$(aws eks describe-cluster --name ${CLUSTER_NAME} --query "cluster.identity.oidc.issuer" --output text ${PROFILE_STRING} --no-cli-pager | cut -d '/' -f 5)
export ADDON_IAM_POLICY_NAME=${CLUSTER_NAME}-addon-${ADDON_NAME}-iam-pol
export ADDON_IAM_ROLE_NAME=${CLUSTER_NAME}-addon-${ADDON_NAME}-iam-rol
export IRSA_NAME=aws-lbc-sa

# AWS LBC 용 IAM Policy 다운로드
curl -o aws-lbc-iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/${ADDON_VERSION}/docs/install/iam_policy.json

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