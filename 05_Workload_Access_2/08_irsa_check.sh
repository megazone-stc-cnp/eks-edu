#!/bin/bash

kubectl get pods | grep my-app

echo "아래 명령을 실행해 주세요"
echo "kubectl describe pod <pod-name> | grep AWS_ROLE_ARN:"

echo "kubectl describe pod <pod-name> | grep AWS_WEB_IDENTITY_TOKEN_FILE:"
