#!/bin/bash

helm list -n kube-system | grep aws-load-balancer-controller