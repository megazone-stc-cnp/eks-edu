#!/bin/bash
if [ -z "$1" ]; then
    echo "사용법: $0 <HELM_VERSION>"
    exit 1
fi
HELM_VERSION=$1

helm upgrade aws-load-balancer-controller \
	eks/aws-load-balancer-controller \
	-n kube-system \
	-f aws-load-balancer-controller-values.yaml \
	--version ${HELM_VERSION}