#!/bin/bash

if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

REPOSITORY_NAME=app_yaml
APP_NAME=my-app
NAMESPACE_NAME=argocd
PROJECT_NAME=default
OWNER_NAME=mzc-ssu-smu-amu
PATH_NAME=kubernetes/helm/my-app
# ==============================================================

# Check if tmp directory exists, if not create it
if [ ! -d "tmp" ]; then
    mkdir -p tmp
fi

cat >tmp/my_app.yaml <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ${APP_NAME}
  namespace: ${NAMESPACE_NAME}
spec:
  project: ${PROJECT_NAME}
  source:
    repoURL: https://github.com/${OWNER_NAME}/${REPOSITORY_NAME}
    targetRevision: HEAD
    path: ${PATH_NAME}
  destination:
    server: arn:aws:eks:${AWS_REGION}:${AWS_ACCOUNT_ID}:cluster/${CLUSTER_NAME}
    namespace: default
EOF

echo "kubectl apply -f tmp/my_app.yaml"
echo ""

kubectl apply -f tmp/my_app.yaml