#!/bin/bash

DEPLOY_NAME=nginx-deploy
# =====================================================================================
echo "kubectl create deploy ${DEPLOY_NAME} --image=public.ecr.aws/nginx/nginx:1.27 --replicas=2"
kubectl create deploy ${DEPLOY_NAME} --image=public.ecr.aws/nginx/nginx:1.27 --replicas=2

echo ""
sh 03_get_pods.sh