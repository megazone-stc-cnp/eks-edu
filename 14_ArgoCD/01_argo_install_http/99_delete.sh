#!/bin/bash

NAMESPACE_NAME=argocd
APP_DEPLOY_NAME=my-argocd
# ==========================================

helm uninstall ${APP_DEPLOY_NAME} -n ${NAMESPACE_NAME}