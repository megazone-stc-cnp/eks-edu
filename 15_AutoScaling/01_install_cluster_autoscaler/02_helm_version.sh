#!/bin/bash

if [ ! -f "./local_env.sh" ];then
	echo "local_env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ./local_env.sh

# ==========================================
if [[ $(helm repo list | grep "^${APP_NAME} " | wc -l) == 0 ]];then
    echo "helm repo add ${REPO_NAME} ${REPO_URL}"
    echo ""
    helm repo add ${REPO_NAME} ${REPO_URL}
fi

echo "helm repo update"
echo ""
helm repo update

echo "helm search repo ${REPO_NAME}/${APP_NAME} --versions"
echo ""
helm search repo ${REPO_NAME}/${APP_NAME} --versions