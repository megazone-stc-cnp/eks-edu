#!/bin/bash

if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh

CLUSTER_NAME=eks-edu-cluster-${EMPLOY_ID}
SERVICE_ACCOUNT_NAME=eks-edu-service-account-${EMPLOY_ID}
POLICY_NAME=eks-edu-workload-policy-${EMPLOY_ID}
ROLE_NAME=eks-edu-workload-role-${EMPLOY_ID}
NAMESPACE_NAME=default
# ==================================================================

echo "eksctl create iamserviceaccount \\
    --name ${SERVICE_ACCOUNT_NAME} \\
    --namespace default \\
    --cluster ${CLUSTER_NAME} \\
    --role-name ${ROLE_NAME} \\
    --attach-policy-arn arn:aws:iam::${AWS_REPO_ACCOUNT}:policy/${POLICY_NAME} --approve"

eksctl create iamserviceaccount \
    --name ${SERVICE_ACCOUNT_NAME} \
    --namespace default \
    --cluster ${CLUSTER_NAME} \
    --role-name ${ROLE_NAME} \
    --attach-policy-arn arn:aws:iam::${AWS_REPO_ACCOUNT}:policy/${POLICY_NAME} --approve