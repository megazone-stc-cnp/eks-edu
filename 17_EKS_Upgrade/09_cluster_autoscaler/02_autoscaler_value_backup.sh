#!/bin/bash

helm get values cluster-autoscaler \
    -n kube-system | tee cluster-autoscaler-values.yaml