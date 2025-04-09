#!/bin/bash

if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

SERVICE_ACCOUNT_NAME=eks-edu-pod-identity-service-account-${IDE_NAME}
POLICY_NAME=eks-edu-pod-identity-workload-policy-${IDE_NAME}
ROLE_NAME=eks-edu-pod-identity-workload-role-${IDE_NAME}
NAMESPACE_NAME=default
# ==================================================================

echo "aws eks create-pod-identity-association \\
    --cluster-name ${CLUSTER_NAME} \\
    --role-arn arn:aws:iam::${AWS_ACCOUNT_ID}:role/${ROLE_NAME} \\
    --namespace ${NAMESPACE_NAME} \\
    --service-account ${SERVICE_ACCOUNT_NAME} ${PROFILE_STRING}"
echo ""

aws eks create-pod-identity-association \
    --cluster-name ${CLUSTER_NAME} \
    --role-arn arn:aws:iam::${AWS_ACCOUNT_ID}:role/${ROLE_NAME} \
    --namespace ${NAMESPACE_NAME} \
    --service-account ${SERVICE_ACCOUNT_NAME} ${PROFILE_STRING}