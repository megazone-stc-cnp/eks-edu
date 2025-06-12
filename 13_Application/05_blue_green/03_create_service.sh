#!/bin/bash

SERVICE_NAME=bluegreen-service
# ==========================================
kubectl expose deployment blue --type=ClusterIP --port=80 --target-port=80 --name ${SERVICE_NAME}