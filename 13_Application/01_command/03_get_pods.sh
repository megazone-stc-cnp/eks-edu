#!/bin/bash

LABEL_NAME=nginx-deploy
# =====================================================================================
echo "kubectl get pods -o wide -L app=${LABEL_NAME}"
kubectl get pods -o wide -L app=${LABEL_NAME}