#!/bin/bash

NAMESPACE_NAME=argocd
# ==========================================
echo "kubectl get ingress -n ${NAMESPACE_NAME}"
echo ""

kubectl get ingress -n ${NAMESPACE_NAME}