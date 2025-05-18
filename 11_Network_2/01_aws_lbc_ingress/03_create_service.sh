#!/bin/bash
if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

SERVICE_NAME=nginx-service
# =================================================================================
# nginx deployment 생성
echo "kubectl create deploy nginx-server --image=nginx --port=80"
kubectl -n app-ns create deploy nginx-server --image=nginx --port=80

# nginx service 생성
echo "kubectl expose deploy nginx-server --name=${SERVICE_NAME} --port=80 --target-port=80"
kubectl -n app-ns  expose deploy nginx-server --name=${SERVICE_NAME} --port=80 --target-port=80