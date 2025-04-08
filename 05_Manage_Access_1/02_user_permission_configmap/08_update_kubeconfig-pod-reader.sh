#!/bin/bash

if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

PROFILE_NAME=eks-edu-profile-${IDE_NAME}
ALIAS_NAME=pod-reader
# ==================================================================

echo "aws eks update-kubeconfig \\
	--name ${CLUSTER_NAME} \\
	--alias "${ALIAS_NAME}" --profile ${PROFILE_NAME}"

aws eks update-kubeconfig \
	--name ${CLUSTER_NAME} \
	--alias "${ALIAS_NAME}" --profile ${PROFILE_NAME}

echo ""
echo "kubectl config get-contexts"
kubectl config get-contexts