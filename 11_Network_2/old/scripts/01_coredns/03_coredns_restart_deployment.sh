#!/bin/bash

echo "kubectl -n kube-system rollout restart deploy coredns"

kubectl -n kube-system rollout restart deploy coredns