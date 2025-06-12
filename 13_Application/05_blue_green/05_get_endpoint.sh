#!/bin/bash

SERVICE_NAME=bluegreen-service
# ==========================================
kubectl get ep ${SERVICE_NAME}
echo ""

kubectl get pods -o wide