#!/bin/bash

if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

# 삭제할 정책 ARN 설정
SERVICE_ACCOUNT_NAME=cluster-autoscaler-sa
POLICY_NAME="cluster-autoscaler-policy-${IDE_NAME}"
ROLE_NAME="cluster-autoscaler-role-${IDE_NAME}"
APP_NAME=cluster-autoscaler
NAMESPACE_NAME=kube-system
# ===================================================================================
POLICY_ARN=arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${POLICY_NAME}

echo "helm uninstall ${APP_NAME} -n ${NAMESPACE_NAME}"
helm uninstall ${APP_NAME} -n ${NAMESPACE_NAME}

echo "eksctl delete iamserviceaccount \\
  --name ${SERVICE_ACCOUNT_NAME} \\
  --namespace kube-system \\
  --cluster ${NAMESPACE_NAME} \\
  --region ${AWS_REGION} \\
  --wait"

eksctl delete iamserviceaccount \
  --name ${SERVICE_ACCOUNT_NAME} \
  --namespace ${NAMESPACE_NAME} \
  --cluster ${CLUSTER_NAME} \
  --region ${AWS_REGION} \
  --wait

POLICY_EXISTS=$(aws iam get-policy --policy-arn ${POLICY_ARN} ${PROFILE_STRING} 2>&1 || echo "POLICY_NOT_FOUND")
if [[ ! "$POLICY_EXISTS" == *"POLICY_NOT_FOUND"* ]]; then
  # 정책 삭제
  echo "aws iam delete-policy --policy-arn ${POLICY_ARN}"
  aws iam delete-policy --policy-arn ${POLICY_ARN}
else
  echo "${POLICY_NAME}이 존재하지 않습니다."
fi