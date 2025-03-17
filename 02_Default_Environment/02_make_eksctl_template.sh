#!/bin/bash
if [ ! -f "../env.sh" ];then
	echo "Root 디렉토리에 env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh

if [ ! -f "./env.sh" ];then
	echo "02_Default_Environment/env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ./env.sh

env
# ==================================================================
if [ ! -d "template" ];then
  mkdir template
fi

envsubst < eksctl.template.yaml > template/eksctl.yamlcl