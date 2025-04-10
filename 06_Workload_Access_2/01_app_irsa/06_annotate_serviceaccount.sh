#!/bin/bash

if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

SERVICE_ACCOUNT_NAME=eks-edu-irsa-service-account-${IDE_NAME}
ROLE_NAME=eks-edu-irsa-workload-role-${IDE_NAME}
NAMESPACE_NAME=default
# ==================================================================

echo "kubectl annotate serviceaccount -n ${NAMESPACE_NAME} ${SERVICE_ACCOUNT_NAME} \\
    eks.amazonaws.com/role-arn=arn:aws:iam::${AWS_ACCOUNT_ID}:role/${ROLE_NAME}"
echo ""

kubectl annotate serviceaccount -n ${NAMESPACE_NAME} ${SERVICE_ACCOUNT_NAME} \
    eks.amazonaws.com/role-arn=arn:aws:iam::${AWS_ACCOUNT_ID}:role/${ROLE_NAME}

echo "kubectl get sa ${SERVICE_ACCOUNT_NAME} -oyaml"
echo ""

kubectl get sa ${SERVICE_ACCOUNT_NAME} -oyaml