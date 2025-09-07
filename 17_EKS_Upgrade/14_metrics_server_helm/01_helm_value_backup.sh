#!/bin/bash

helm get values metrics-server \
    -n kube-system | tee metrics-server-values.yaml