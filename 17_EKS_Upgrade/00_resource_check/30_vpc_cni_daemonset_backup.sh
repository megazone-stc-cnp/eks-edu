#!/bin/bash

if [ ! -d "tmp" ]; then
    mkdir -p tmp
fi

kubectl get daemonset aws-node -n kube-system -o yaml | tee tmp/aws-node-daemonset-backup.yaml