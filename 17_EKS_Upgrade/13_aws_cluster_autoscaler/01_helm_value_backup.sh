#!/bin/bash

helm get values cluster-autoscaler \
    -n kube-system | tee aws-cluster-autoscaler-values.yaml