#!/bin/bash


if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh

# ==================================================================

echo "aws eks update-kubeconfig \\
	--name ${CLUSTER_NAME} \\
	--alias ${CLUSTER_NAME} ${PROFILE_STRING}"

aws eks update-kubeconfig \
	--name ${CLUSTER_NAME} \
	--alias "${CLUSTER_NAME}" ${PROFILE_STRING}

kubectl config get-contexts