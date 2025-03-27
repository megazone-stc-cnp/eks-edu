#!/bin/bash
if [ ! -f "../env.sh" ];then
	echo "Root 디렉토리에 env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh

if [ ! -f "./local_env.sh" ];then
	echo "02_Default_Environment/env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ./local_env.sh

# ==================================================================
if [ ! -d "template" ];then
  mkdir template
fi
eksctl-cluster-nodegroup.template.yaml
if [ -f "template/eksctl.yaml" ];then
	rm -rf template/eksctl.yaml
fi

envsubst < eksctl-cluster-nodegroup.yaml.template > template/eksctl.yaml

cat template/eksctl.yaml