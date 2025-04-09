#!/bin/bash

APP_NAME=pod-identity-app
# ==================================================================

echo "kubectl get pods -l app=${APP_NAME}"
kubectl get pods -l app=${APP_NAME}

echo "=============================================="
POD_NAME=$(kubectl get pods -l app=${APP_NAME} | awk '{print $1}')
kubectl describe pod ${POD_NAME} | grep AWS_CONTAINER_AUTHORIZATION_TOKEN_FILE

