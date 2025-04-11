#!/bin/bash

APP_NAME=irsa-app
NAMESPACE_NAME=default
# ==================================================================

echo "kubectl get pods -l app=${APP_NAME}"
echo ""
kubectl get pods -l app=${APP_NAME}

POD_NAME=$(kubectl get pods -l app=${APP_NAME} -oname)
echo "kubectl -n ${NAMESPACE_NAME} describe ${POD_NAME} | grep AWS_ROLE_ARN:"
echo ""
kubectl -n ${NAMESPACE_NAME} describe ${POD_NAME} | grep AWS_ROLE_ARN:

echo ""
echo "kubectl -n ${NAMESPACE_NAME} describe ${POD_NAME} | grep AWS_WEB_IDENTITY_TOKEN_FILE:"
echo ""
kubectl -n ${NAMESPACE_NAME} describe ${POD_NAME} | grep AWS_WEB_IDENTITY_TOKEN_FILE:
echo ""