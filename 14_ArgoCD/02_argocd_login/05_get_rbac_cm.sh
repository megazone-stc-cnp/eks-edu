#!/bin/bash

NAMESPACE_NAME=argocd
# =============================================
echo "kubectl -n ${NAMESPACE_NAME} get configmap argocd-rbac-cm -oyaml"
echo ""

kubectl -n ${NAMESPACE_NAME} get configmap argocd-rbac-cm -oyaml