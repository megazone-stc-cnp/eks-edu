#!/bin/bash

NAMESPACE_NAME=default
APP_DEPLOY_NAME=bitnami-nginx
# ==========================================
echo "helm -n ${NAMESPACE_NAME} uninstall ${APP_DEPLOY_NAME}"

helm -n ${NAMESPACE_NAME} uninstall ${APP_DEPLOY_NAME}