#!/bin/bash

INGRESS_NAME=my-argocd-server
NAMESPACE_NAME=argocd
# =====================================
INGRESS_ADDRESS=$(kubectl get ingress ${INGRESS_NAME} -n ${NAMESPACE_NAME} -o jsonpath="{.status.loadBalancer.ingress[0].hostname}")
echo "argocd login ${INGRESS_ADDRESS}:80 --insecure --username admin --skip-test-tls --plaintext --grpc-web"
echo ""

argocd login ${INGRESS_ADDRESS}:80 --insecure --username admin --skip-test-tls --plaintext --grpc-web