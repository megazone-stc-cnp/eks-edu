#!/bin/bash

if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

NAMESPACE_NAME=argocd
# ==============================================================

echo "kubectl get secrets -n ${NAMESPACE_NAME} -l argocd.argoproj.io/secret-type=cluster"
echo ""

kubectl get secrets -n ${NAMESPACE_NAME} -l argocd.argoproj.io/secret-type=cluster