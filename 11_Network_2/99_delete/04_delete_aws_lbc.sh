#!/bin/bash
if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

export ADDON_NAME="aws-lbc"
export ADDON_IAM_POLICY_NAME=${CLUSTER_NAME}-addon-${ADDON_NAME}-iam-pol
NAMESPACE_NAME=kube-system
# =============================================================================

aws iam list-policies --query "Policies[?PolicyName=='${ADDON_IAM_POLICY_NAME}'].Arn" --output text --no-cli-pager

helm uninstall aws-load-balancer-controller -n ${NAMESPACE_NAME}