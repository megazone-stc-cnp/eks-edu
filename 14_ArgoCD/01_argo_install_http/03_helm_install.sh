#!/bin/bash

if [ -z "$1" ]; then
    echo "사용법: $0 <CHART_VERSION>"
    exit 1
fi
CHART_VERSION=$1

if [ ! -d "tmp" ]; then
    mkdir -p tmp
fi

cat >tmp/custom_values.yaml <<EOF
global:
  domain: ""

configs:
  params:
    server.insecure: true

server:
  extraArgs:
    - --insecure
  ingress:
    enabled: true
    ingressClassName: alb
    hostname: ""
    annotations:
      alb.ingress.kubernetes.io/scheme: internet-facing
      alb.ingress.kubernetes.io/target-type: ip
      alb.ingress.kubernetes.io/backend-protocol: HTTP
      alb.ingress.kubernetes.io/listen-ports: '[{"HTTP":80}]'
      alb.ingress.kubernetes.io/security-groups: sg-09283f6474746392a
      alb.ingress.kubernetes.io/manage-backend-security-group-rules: "true"
      alb.ingress.kubernetes.io/deletion-protection.enabled: false
      alb.ingress.kubernetes.io/healthcheck-interval-seconds: "15"
      alb.ingress.kubernetes.io/healthcheck-path: /healthz
    hosts: []  # 빈 배열로 설정
EOF

REPO_NAME=argo
APP_NAME=argo-cd
NAMESPACE_NAME=argocd
APP_DEPLOY_NAME=my-argocd
# ==========================================

echo "helm -n ${NAMESPACE_NAME} upgrade --install ${APP_DEPLOY_NAME} \\
    ${REPO_NAME}/${APP_NAME} \\
    --create-namespace \\
    -f tmp/custom_values.yaml \\
    --version ${CHART_VERSION}"
echo ""

helm -n ${NAMESPACE_NAME} upgrade --install ${APP_DEPLOY_NAME} \
    ${REPO_NAME}/${APP_NAME} \
    --create-namespace \
    -f tmp/custom_values.yaml \
    --version ${CHART_VERSION}