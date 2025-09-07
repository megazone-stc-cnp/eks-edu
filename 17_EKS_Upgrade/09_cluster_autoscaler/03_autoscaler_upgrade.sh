#!/bin/bash

helm repo update
helm upgrade cluster-autoscaler \
	cluster-autoscaler/cluster-autoscaler \
	-n kube-system \
	-f cluster-autoscaler-values.yaml \
	--version 9.37.0