#!/bin/bash

NAMESPACE_NAME=argocd
# ==========================================
echo "kubectl -n ${NAMESPACE_NAME} get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 -d; echo"
echo ""

kubectl -n ${NAMESPACE_NAME} get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo