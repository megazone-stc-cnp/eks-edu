#!/bin/bash
if [ -z "$1" ]; then
    echo "사용법: $0 <HELM_VERSION>"
    exit 1
fi
HELM_VERSION=$1

helm upgrade cluster-autoscaler \
	cluster-autoscaler/cluster-autoscaler \
	-n kube-system \
	-f aws-cluster-autoscaler-values.yaml \
	--version ${HELM_VERSION}