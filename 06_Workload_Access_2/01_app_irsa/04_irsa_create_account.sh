#!/bin/bash

if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

SERVICE_ACCOUNT_NAME=eks-edu-irsa-service-account-${IDE_NAME}
POLICY_NAME=eks-edu-irsa-workload-policy-${IDE_NAME}
ROLE_NAME=eks-edu-irsa-workload-role-${IDE_NAME}
NAMESPACE_NAME=default
# ==================================================================
if [ ! -d "tmp" ]; then
    mkdir -p tmp
fi

cat >tmp/eks-edu-irsa-service-account.yaml <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ${SERVICE_ACCOUNT_NAME}
  namespace: ${NAMESPACE_NAME}
EOF
echo "kubectl apply -f tmp/eks-edu-irsa-service-account.yaml"
echo ""

kubectl apply -f tmp/eks-edu-irsa-service-account.yaml

echo "kubectl get sa"
echo ""
kubectl get sa