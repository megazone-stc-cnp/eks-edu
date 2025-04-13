#!/bin/bash

if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh

# envsubst < addon-config-template.yaml
eksctl delete addon --cluster $CLUSTER_NAME --name eks-node-monitoring-agent