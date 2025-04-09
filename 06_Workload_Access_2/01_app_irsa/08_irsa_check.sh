#!/bin/bash

APP_NAME=irsa-app
NAMESPACE_NAME=default
# ==================================================================

echo "kubectl get pods -l app=${APP_NAME}"
echo ""
kubectl get pods -l app=${APP_NAME}

echo "아래 명령을 실행해 주세요"
echo ""

POD_NAME=$(kubectl get pods -l app=${APP_NAME} | awk '{print $1}')
echo "kubectl -n ${NAMESPACE_NAME} describe pod ${POD_NAME} | grep AWS_ROLE_ARN:"
kubectl -n ${NAMESPACE_NAME} describe pod ${POD_NAME} | grep AWS_ROLE_ARN:

echo ""
echo "kubectl -n ${NAMESPACE_NAME} describe pod ${POD_NAME} | grep AWS_WEB_IDENTITY_TOKEN_FILE:"
kubectl -n ${NAMESPACE_NAME} describe pod ${POD_NAME} | grep AWS_WEB_IDENTITY_TOKEN_FILE:
