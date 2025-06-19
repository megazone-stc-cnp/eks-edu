#!/bin/bash

REPO_NAME=argo
# ==============================================================
echo "helm repo add ${REPO_NAME} https://argoproj.github.io/argo-helm"
echo ""
helm repo add ${REPO_NAME} https://argoproj.github.io/argo-helm

echo "helm repo update"
echo ""
helm repo update