#!/bin/bash

DEPLOY_NAME=deploy-nginx
# =====================================================================================
echo "kubectl create deploy ${DEPLOY_NAME} --image=public.ecr.aws/nginx/nginx:1.28 --replicas=3"
kubectl create deploy ${DEPLOY_NAME} --image=public.ecr.aws/nginx/nginx:1.28 --replicas=3

echo ""
sh 02_get_pods.sh