#!/bin/bash

if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh

SERVICE_ACCOUNT_NAME=eks-edu-irsa-service-account-${IDE_NAME}
POLICY_NAME=eks-edu-irsa-workload-policy-${IDE_NAME}
ROLE_NAME=eks-edu-irsa-workload-role-${IDE_NAME}
NAMESPACE_NAME=default
# ==================================================================

cat >eks-edu-irsa-service-account.yaml <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ${SERVICE_ACCOUNT_NAME}
  namespace: ${NAMESPACE_NAME}
EOF
kubectl apply -f eks-edu-irsa-service-account.yaml

kubectl get sa