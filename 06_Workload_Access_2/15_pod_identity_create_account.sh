#!/bin/bash

if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh

SERVICE_ACCOUNT_NAME=eks-edu-pod-identity-service-account-${IDE_NAME}
NAMESPACE_NAME=default
# ==================================================================

cat >eks-edu-pod-identity-service-account.yaml <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ${SERVICE_ACCOUNT_NAME}
  namespace: ${NAMESPACE_NAME}
EOF
kubectl apply -f eks-edu-pod-identity-service-account.yaml

kubectl describe sa ${SERVICE_ACCOUNT_NAME}