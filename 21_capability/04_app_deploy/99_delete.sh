#!/bin/bash
if [ ! -f "../../env.sh" ];then
	echo "Root 디렉토리에 env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

CAPABILITY_NAME=argocd-${IDE_NAME}
ARGOCD_CAPABILITY_ROLE_NAME=eks-edu-argocd-capability-role-${IDE_NAME}
# export AWS_REGION=ap-northeast-2
# ======================================================
if [ -f "tmp/my_app.yaml" ]; then
  echo "kubectl delete -f tmp/my_app.yaml"
  echo ""

  kubectl delete -f tmp/my_app.yaml
fi