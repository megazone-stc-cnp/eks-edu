#!/bin/bash

INGRESS_ADDRESS=$(kubectl get ingress my-argocd-server -n argocd -o jsonpath="{.status.loadBalancer.ingress[0].hostname}")
argocd login ${INGRESS_ADDRESS}:80 --insecure --username admin --skip-test-tls --plaintext --grpc-web