#!/bin/bash

kubectl get cm coredns -n kube-system -o yaml | kubectl neat | tee coredns-cm-backup.yaml