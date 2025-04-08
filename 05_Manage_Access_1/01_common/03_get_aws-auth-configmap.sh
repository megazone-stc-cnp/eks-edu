#!/bin/bash

if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

# ==================================================================

echo "kubectl -n kube-system get configmap aws-auth -oyaml"

kubectl -n kube-system get configmap aws-auth -oyaml