#!/bin/bash
if [ ! -f "../.env" ];then
	echo "Root 디렉토리에 .env 파일 세팅을 해주세요."
	exit 1
fi
. ../.env

if [ ! -f "./.env" ];then
	echo "02_Default_Environment/.env 파일 세팅을 해주세요."
	exit 1
fi
. ./.env
# ==================================================================
if [ ! -d "template" ];then
  mkdir template
fi

envsubst < cluster.template.yaml > template/cluster.yaml