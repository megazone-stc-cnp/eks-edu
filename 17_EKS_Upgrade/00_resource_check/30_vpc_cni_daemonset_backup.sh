#!/bin/bash

kubectl get daemonset aws-node -n kube-system -o yaml | kubectl neat | tee aws-node-daemonset-backup.yaml