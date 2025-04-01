#!/bin/bash

# https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/lbc-helm.html

echo "helm repo add eks https://aws.github.io/eks-charts"

echo "helm repo update eks"

helm repo add eks https://aws.github.io/eks-charts

helm repo update eks