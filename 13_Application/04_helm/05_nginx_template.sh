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
# ==========================================

echo "helm template -f tmp/custom_values.yaml ${REPO_NAME}/${APP_NAME} --version ${CHART_VERSION}"
helm template -f tmp/custom_values.yaml ${REPO_NAME}/${APP_NAME} --version ${CHART_VERSION}