#!/bin/bash

kubectl get pods | grep pod-identity-app

echo "=============================================="
POD_NAME=$(kubectl get pods | grep pod-identity-app | awk '{print $1}')
kubectl describe pod ${POD_NAME} | grep AWS_CONTAINER_AUTHORIZATION_TOKEN_FILE

