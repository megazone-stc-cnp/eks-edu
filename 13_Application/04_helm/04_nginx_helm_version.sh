#!/bin/bash

REPO_NAME=bitnami
APP_NAME=nginx
# ==========================================

echo "helm search repo bitnami/nginx --versions"
helm search repo bitnami/nginx --versions