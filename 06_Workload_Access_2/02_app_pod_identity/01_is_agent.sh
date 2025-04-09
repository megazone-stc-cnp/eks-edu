#!/bin/bash

if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

# ==================================================================
echo "kubectl get pods -n kube-system | grep 'eks-pod-identity-agent'"
echo ""

kubectl get pods -n kube-system | grep 'eks-pod-identity-agent'