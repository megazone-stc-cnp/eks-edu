#!/bin/bash

REPO_NAME=bitnami
# ==============================================================
echo "helm repo add ${REPO_NAME} https://charts.bitnami.com/bitnami"
helm repo add ${REPO_NAME} https://charts.bitnami.com/bitnami

echo "helm repo update"
helm repo update