#!/bin/bash

if [ -z "$1" ]; then
    echo "사용법: $0 <ADMIN_PASSWORD>"
    exit 1
fi
ADMIN_PASSWORD=$1

NEW_USER_NAME=user1
NEW_USER_PASSWORD=user1pass
NAMESPACE_NAME=argocd
APP_DEPLOY_NAME=my-argocd
# =============================================
kubectl -n ${NAMESPACE_NAME} patch configmap argocd-cm \
  --type merge \
  -p "{\"data\": {\"accounts.${NEW_USER_NAME}\": \"apiKey, login\"}}"

echo "argocd account update-password \\
        --account ${NEW_USER_NAME} \\
        --current-password ${ADMIN_PASSWORD} \\
        --new-password ${NEW_USER_PASSWORD}"

argocd account update-password \
  --account ${NEW_USER_NAME} \
  --current-password ${ADMIN_PASSWORD} \
  --new-password ${NEW_USER_PASSWORD}

echo "USER : ${NEW_USER_NAME}"
echo "PASSWORD : ${NEW_USER_PASSWORD}"

echo "kubectl -n ${NAMESPACE_NAME} rollout restart deployment ${APP_DEPLOY_NAME}-server"
kubectl -n ${NAMESPACE_NAME} rollout restart deployment ${APP_DEPLOY_NAME}-server
echo ""