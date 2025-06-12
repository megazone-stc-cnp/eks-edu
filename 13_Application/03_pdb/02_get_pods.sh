#!/bin/bash

LABEL_NAME=deploy-nginx
# =====================================================================================
echo "kubectl get pods -o wide -L app=${LABEL_NAME}"
kubectl get pods -o wide -L app=${LABEL_NAME}