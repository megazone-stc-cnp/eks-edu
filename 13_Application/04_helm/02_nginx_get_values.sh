#!/bin/bash
REPO_NAME=bitnami
APP_NAME=nginx
# ==========================================
if [ ! -d "tmp" ]; then
    mkdir -p tmp
fi

echo "helm show values ${REPO_NAME}/${APP_NAME} > tmp/values.yaml"
helm show values ${REPO_NAME}/${APP_NAME} > tmp/values.yaml

