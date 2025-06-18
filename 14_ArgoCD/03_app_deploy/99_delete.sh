#!/bin/bash

DEPLOY_NAME=test
ARGOCD_NAMESPACE_NAME=argocd
# ==========================================

kubectl delete application ${DEPLOY_NAME} -n ${ARGOCD_NAMESPACE_NAME}