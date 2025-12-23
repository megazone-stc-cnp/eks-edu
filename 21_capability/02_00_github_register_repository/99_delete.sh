#!/bin/bash

if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

NAMESPACE_NAME=argocd
REPOSITORY_NAME=app_yaml
# ==============================================================
echo "kubectl delete -f tmp/create_secret.yaml"
kubectl delete -f tmp/create_secret.yaml

SECRETS_MANAGER_EXISTS=$(aws secretsmanager describe-secret --region ${AWS_REGION} --secret-id ${NAMESPACE_NAME}/${REPOSITORY_NAME} ${PROFILE_STRING} 2>&1 || echo "NOT_FOUND")

if [[ ! "$SECRETS_MANAGER_EXISTS" == *"NOT_FOUND"* ]]; then
  aws secretsmanager delete-secret \
    --secret-id ${NAMESPACE_NAME}/${REPOSITORY_NAME} \
    --region ${AWS_REGION} ${PROFILE_STRING}
fi


