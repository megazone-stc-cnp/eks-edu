#!/bin/bash

APP_NAME=pod-identity-app
NAMESPACE_NAME=default
# ==================================================================

echo "kubectl -n ${NAMESPACE_NAME} get pods -l app=${APP_NAME}"
kubectl -n ${NAMESPACE_NAME} get pods -l app=${APP_NAME}
echo ""

POD_NAME=$(kubectl -n ${NAMESPACE_NAME} get pods -l app=${APP_NAME} kubectl -n default get pods -l app=pod-identity-app -oname)
echo "POD_NAME: ${POD_NAME}"
echo ""

echo "kubectl -n ${NAMESPACE_NAME} describe ${POD_NAME} | grep AWS_CONTAINER_AUTHORIZATION_TOKEN_FILE"
echo ""
kubectl -n ${NAMESPACE_NAME} describe ${POD_NAME} | grep AWS_CONTAINER_AUTHORIZATION_TOKEN_FILE

