#!/bin/bash
if [ ! -f "../../env.sh" ];then
	echo "Root 디렉토리에 env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

if [ ! -f "../../vpc_env.sh" ];then
	echo "01_create_vpc 를 진행해 주세요."
	exit 1
fi
. ../../vpc_env.sh

# ==================================================================
if [ ! -d "template" ];then
  mkdir template
fi

if [ -f "template/eksctl.yaml" ];then
	rm -rf template/eksctl.yaml
fi

echo "envsubst < eksctl-cluster-nodegroup-pod-identity-addon.yaml.template > template/eksctl.yaml"
echo ""
envsubst < eksctl-cluster-nodegroup-pod-identity-addon.yaml.template > template/eksctl.yaml

cat template/eksctl.yaml