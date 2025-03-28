#!/bin/bash

if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh
# export AWS_REGION=
# export EMPLOY_ID=
# export PROFILE_NAME=
# export AWS_REPO_ACCOUNT=
if [ ! -f "./local_env.sh" ];then
	echo "local_env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ./local_env.sh
# export OIDC_ID=

SERVICE_ACCOUNT_NAME=eks-edu-service-account-${EMPLOY_ID}
POLICY_NAME=eks-edu-workload-policy-${EMPLOY_ID}
ROLE_NAME=eks-edu-workload-role-${EMPLOY_ID}
NAMESPACE_NAME=default
# ==================================================================

kubectl annotate serviceaccount -n ${NAMESPACE_NAME} ${SERVICE_ACCOUNT_NAME} \
    eks.amazonaws.com/role-arn=arn:aws:iam::${AWS_REPO_ACCOUNT}:role/${ROLE_NAME}

echo "kubectl get sa eks-edu-service-account-${EMPLOY_ID} -oyaml"

kubectl get sa eks-edu-service-account-${EMPLOY_ID} -oyaml