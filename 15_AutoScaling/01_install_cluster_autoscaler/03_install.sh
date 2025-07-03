#!/bin/bash

if [ -z "$1" ]; then
    echo "사용법: $0 <CHART_VERSION>"
    exit 1
fi
CHART_VERSION=$1

if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

if [ ! -f "./local_env.sh" ];then
	echo "local_env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ./local_env.sh

ROLE_NAME="${APP_NAME}-role-${IDE_NAME}"
# ==================================================================
if [ ! -d "tmp" ]; then
    mkdir -p tmp
fi

echo "${HELM_VALUE_YAML}" > tmp/${APP_NAME}-value.yaml

echo "helm upgrade --install ${APP_NAME} ${REPO_NAME}/${CHART_NAME} \\
        --version "${CHART_VERSION}" \\
        --namespace ${NAMESPACE_NAME} \\
        -f tmp/${APP_NAME}-value.yaml \\
        --wait"

helm upgrade --install ${APP_NAME} ${REPO_NAME}/${CHART_NAME} \
  --version "${CHART_VERSION}" \
  --namespace ${NAMESPACE_NAME} \
  -f tmp/${APP_NAME}-value.yaml \
  --wait