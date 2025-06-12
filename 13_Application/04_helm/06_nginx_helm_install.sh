#!/bin/bash

if [ -z "$1" ]; then
    echo "사용법: $0 <CHART_VERSION>"
    exit 1
fi
CHART_VERSION=$1

if [ ! -f "tmp/custom_values.yaml" ];then
	echo "03 단계를 실행해 주세요."
	exit 1
fi

REPO_NAME=bitnami
APP_NAME=nginx
NAMESPACE_NAME=default
APP_DEPLOY_NAME=bitnami-nginx
# ==========================================

echo "helm -n ${NAMESPACE_NAME} install ${APP_DEPLOY_NAME} \\
    ${REPO_NAME}/${APP_NAME} \\
    -f tmp/custom_values.yaml \\
    --version ${CHART_VERSION}"
echo ""

helm -n ${NAMESPACE_NAME} install ${APP_DEPLOY_NAME} \
    ${REPO_NAME}/${APP_NAME} \
    -f tmp/custom_values.yaml \
    --version ${CHART_VERSION}