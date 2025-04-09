#!/bin/bash

if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

SERVICE_ACCOUNT_NAME=eks-edu-service-account-${IDE_NAME}
POLICY_NAME=eks-edu-irsa-workload-policy-${IDE_NAME}
ROLE_NAME=eks-edu-irsa-workload-role-${IDE_NAME}
NAMESPACE_NAME=default
# ==================================================================

echo "eksctl create iamserviceaccount \\
    --name ${SERVICE_ACCOUNT_NAME} \\
    --namespace ${NAMESPACE_NAME} \\
    --cluster ${CLUSTER_NAME} \\
    --role-name ${ROLE_NAME} \\
    --attach-policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${POLICY_NAME} --approve"
echo ""

eksctl create iamserviceaccount \
    --name ${SERVICE_ACCOUNT_NAME} \
    --namespace ${NAMESPACE_NAME} \
    --cluster ${CLUSTER_NAME} \
    --role-name ${ROLE_NAME} \
    --attach-policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${POLICY_NAME} --approve