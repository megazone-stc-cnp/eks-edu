#!/bin/bash

POD_NAME=ebs-dynamic-app
# ====================================================================
echo "kubectl exec ${POD_NAME} -- cat /data/out.txt"

kubectl exec ${POD_NAME} -- cat /data/out.txt