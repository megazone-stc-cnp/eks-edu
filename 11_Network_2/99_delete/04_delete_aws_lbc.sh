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

# NLB SG 삭제
. ../02_aws_lbc_target_group_binding/local_env.sh
aws ec2 delete-security-group --group-id ${NLB_SECURITY_GROUP_ID} --no-cli-pager
# NLB Target Group 삭제
aws elbv2 delete-target-group --target-group-arn ${TARGET_GROUP_ARN} --no-cli-pager

# ALB SG 삭제
. ../01_aws_lbc_ingress/local_env.sh
aws ec2 delete-security-group --group-id ${ALB_SECURITY_GROUP_ID} --no-cli-pager

# IAM Policy 삭제
POLICY_ARN=$(aws iam list-policies --query "Policies[?PolicyName=='${ADDON_IAM_POLICY_NAME}'].Arn" --output text --no-cli-pager)
aws iam delete-policy --policy-arn ${POLICY_ARN} --no-cli-pager

# Helm Uninstall
helm uninstall aws-load-balancer-controller -n ${NAMESPACE_NAME}