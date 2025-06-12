#!/bin/bash

DEPLOY_NAME=deploy-nginx
# =====================================================================================
kubectl delete deploy ${DEPLOY_NAME}