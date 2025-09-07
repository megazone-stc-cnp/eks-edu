#!/bin/bash

helm get values aws-load-balancer-controller \
    -n kube-system | tee aws-load-balancer-controller-values.yaml