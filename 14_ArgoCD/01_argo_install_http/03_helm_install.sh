#!/bin/bash

if [ -z "$1" ]; then
    echo "사용법: $0 <CHART_VERSION>"
    exit 1
fi
CHART_VERSION=$1

cat >tmp/custom_values.yaml <<EOF
global:
  domain: ""

configs:
  params:
    server.insecure: true

service:
  type: ClusterIP
  port: 80
  targetPort: 8080

server:
  extraArgs:
    - --insecure
  ingressGrpc:
    enabled: false
  ingress:
    enabled: true
    controller: aws
    ingressClassName: alb
    annotations:
      alb.ingress.kubernetes.io/scheme: internet-facing
      alb.ingress.kubernetes.io/target-type: ip
      alb.ingress.kubernetes.io/backend-protocol: HTTP
      alb.ingress.kubernetes.io/listen-ports: '[{"HTTP":80}]'
    hosts: []  # 빈 배열로 설정
    aws:
      serviceType: ClusterIP # <- Used with target-type: ip
      backendProtocolVersion: HTTP1
    paths:
      - /
    pathType: Prefix

# TLS 비활성화 (HTTP 사용)
tls: []
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