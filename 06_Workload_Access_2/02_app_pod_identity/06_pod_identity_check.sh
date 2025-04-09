#!/bin/bash

APP_NAME=pod-identity-app
NAMESPACE_NAME=default
# ==================================================================

echo "kubectl -n ${NAMESPACE_NAME} get pods -l app=${APP_NAME}"
kubectl -n ${NAMESPACE_NAME} get pods -l app=${APP_NAME}

echo "=============================================="
POD_NAME=$(kubectl -n ${NAMESPACE_NAME} get pods -l app=${APP_NAME} | awk '{print $1}')
kubectl -n ${NAMESPACE_NAME} describe pod ${POD_NAME} | grep AWS_CONTAINER_AUTHORIZATION_TOKEN_FILE

