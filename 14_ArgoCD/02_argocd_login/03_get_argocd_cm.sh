#!/bin/bash

NAMESPACE_NAME=argocd
# =============================================

kubectl -n ${NAMESPACE_NAME} get configmap argocd-cm -o yaml