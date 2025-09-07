#!/bin/bash

if [ ! -d "tmp" ]; then
    mkdir -p tmp
fi

kubectl get cm coredns -n kube-system -o yaml | tee tmp/coredns-cm-backup.yaml