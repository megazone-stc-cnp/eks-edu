#!/bin/bash

NAMESPACE_NAME=argocd
# =============================================
kubectl -n ${NAMESPACE_NAME} get configmap argocd-rbac-cm -oyaml