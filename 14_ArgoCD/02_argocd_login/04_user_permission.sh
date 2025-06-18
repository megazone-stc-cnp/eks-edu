#!/bin/bash

NEW_USER_NAME=user1
NAMESPACE_NAME=argocd
ROLE_NAME=admin
# ROLE_NAME=readonly
# =============================================
kubectl -n ${NAMESPACE_NAME} patch configmap argocd-rbac-cm \
  --type merge \
  -p $"{\"data\":{\"policy.csv\":\"g, ${NEW_USER_NAME}, role:${ROLE_NAME}\\n\"}}"