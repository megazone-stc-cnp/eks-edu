#!/bin/bash
if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

NAMESPACE_NAME=kube-system
# =============================================================================

kubectl -n ${NAMESPACE_NAME} delete ingress alb-ingress-manager

kubectl -n default delete ingress nginx-ingress