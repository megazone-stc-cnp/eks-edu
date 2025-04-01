#!/bin/bash

RELEASE_VERSION=v2.12.0
# ===============================================================================================================
if [ ! -d "tmp" ]; then
    mkdir -p tmp
fi

curl -o tmp/iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/${RELEASE_VERSION}/docs/install/iam_policy.json
