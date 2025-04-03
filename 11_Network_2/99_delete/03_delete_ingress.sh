#!/bin/bash
if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

NAMESPACE_NAME=kube-system
SERVICE_ACCOUNT_NAME=alb-controller-sa
ROLE_NAME=eks-edu-aws-load-balancer-controller-role-${IDE_NAME}
REPO_FULLPATH=public.ecr.aws/eks/aws-load-balancer-controller
ORIGIN_TAG=v2.9.2
# =============================================================================

kubectl -n ${NAMESPACE_NAME} delete ingress alb-ingress-manager

kubectl -n default delete ingress nginx-ingress