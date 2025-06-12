#!/bin/bash

SERVICE_NAME=bluegreen-service
# ==========================================
kubectl patch service ${SERVICE_NAME} \
  -p '{"spec": {"selector": {"version": "green"}}}'

echo ""
sh 05_get_endpoint.sh