#!/bin/bash

APP_NAME=irsa-app
# ==================================================================

echo "kubectl get pods -l app=${APP_NAME}"
echo ""
kubectl get pods -l app=${APP_NAME}

echo "아래 명령을 실행해 주세요"
echo ""
echo "kubectl describe pod <pod-name> | grep AWS_ROLE_ARN:"
echo ""
echo "kubectl describe pod <pod-name> | grep AWS_WEB_IDENTITY_TOKEN_FILE:"
