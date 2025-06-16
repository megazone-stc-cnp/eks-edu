#!/bin/bash

REPO_NAME=argo
APP_NAME=argo-cd
# ==========================================

echo "helm search repo ${REPO_NAME}/${APP_NAME} --versions"
helm search repo ${REPO_NAME}/${APP_NAME} --versions