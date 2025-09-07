#!/bin/bash
if [ -z "$1" ]; then
    echo "사용법: $0 <HELM_VERSION>"
    exit 1
fi
HELM_VERSION=$1

helm upgrade metrics-server \
	metrics-server/metrics-server \
	-n kube-system \
	-f metrics-server-values.yaml \
	--version ${HELM_VERSION}