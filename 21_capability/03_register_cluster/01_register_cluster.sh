#!/bin/bash

if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

PROJECT_NAME=default
# ==============================================================
# # For AWS managed ArgoCD, we need to use SSO login
if [ ! -d "tmp" ]; then
    mkdir -p tmp
fi

# # Check if cluster is already registered
cat >tmp/create_kubernetes_secret.yaml <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: ${CLUSTER_NAME}
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: cluster
stringData:
  name: ${CLUSTER_NAME}
  server: arn:aws:eks:${AWS_REGION}:${AWS_ACCOUNT_ID}:cluster/${CLUSTER_NAME}
  project: ${PROJECT_NAME}
EOF

echo "kubectl apply -f tmp/create_kubernetes_secret.yaml"
kubectl apply -f tmp/create_kubernetes_secret.yaml