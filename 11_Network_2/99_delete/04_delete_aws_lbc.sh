#!/bin/bash
if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

NAMESPACE_NAME=kube-system
# =============================================================================

helm uninstall aws-load-balancer-controller -n ${NAMESPACE_NAME}