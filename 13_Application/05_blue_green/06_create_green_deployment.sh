#!/bin/bash

DEPLOY_NAME=green
TAG_VERSION=1.28
# ===================================
if [ ! -d "tmp" ]; then
    mkdir -p tmp
fi


cat >tmp/green-deployment.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${DEPLOY_NAME}
spec:
  replicas: 2
  selector:
    matchLabels:
      version: ${DEPLOY_NAME}
  template:
    metadata:
      labels:
        version: ${DEPLOY_NAME}
    spec:
      containers:
      - image: public.ecr.aws/nginx/nginx:${TAG_VERSION}
        name: nginx
        ports:
        - containerPort: 80
EOF

echo "kubectl apply -f tmp/green-deployment.yaml"
echo ""
kubectl apply -f tmp/green-deployment.yaml

echo ""
sh 02_get_deploy.sh

