#!/usr/bin/env bash

if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

# ==============================================================
echo "kubectl delete -f tmp/create_kubernetes_secret.yaml"
echo ""
kubectl delete -f tmp/create_kubernetes_secret.yaml