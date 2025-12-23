#!/bin/bash

if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

if [ ! -f "./local_env.sh" ];then
	echo "local_env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ./local_env.sh
# SECRET_MANAGER_ARN

SECRET_NAME=app-yaml
REPOSITORY_NAME=app_yaml
NAMESPACE_NAME=argocd
OWNER_NAME=mzc-ssu-smu-amu
PROJECT_NAME=default
# ==============================================================
# Check if tmp directory exists, if not create it
if [ ! -d "tmp" ]; then
    mkdir -p tmp
fi

cat >tmp/create_secret.yaml <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: ${SECRET_NAME}
  namespace: ${NAMESPACE_NAME}
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: https://github.com/${OWNER_NAME}/${REPOSITORY_NAME}
  secretArn: ${SECRET_MANAGER_ARN}
  project: default
EOF

echo tmp/create_secret.yaml
echo ""

echo "kubectl apply -f tmp/create_secret.yaml"
echo ""

kubectl apply -f tmp/create_secret.yaml