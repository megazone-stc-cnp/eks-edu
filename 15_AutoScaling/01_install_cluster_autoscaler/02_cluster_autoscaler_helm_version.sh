#!/bin/bash

REPO_NAME=autoscaler
APP_NAME=cluster-autoscaler
# ==========================================
if [[ $(helm repo list | grep "^${APP_NAME} " | wc -l) == 0 ]];then
    helm repo add ${REPO_NAME} https://kubernetes.github.io/autoscaler
fi
helm repo update

echo "helm search repo ${REPO_NAME}/${APP_NAME} --versions"
helm search repo ${REPO_NAME}/${APP_NAME} --versions