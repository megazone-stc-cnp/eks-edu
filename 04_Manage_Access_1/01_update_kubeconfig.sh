#!/bin/bash


if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh

CLUSTER_NAME=eks-edu-cluster-${EMPLOY_ID}
# ==================================================================
PROFILE_STRING=""
if [ -n "$PROFILE_NAME" ]; then
    PROFILE_STRING="--profile ${PROFILE_NAME}"
fi

echo "aws eks update-kubeconfig \\
	--name ${CLUSTER_NAME} \\
	--alias "${CLUSTER_NAME}" \\
	${AWS_REGION} ${PROFILE_STRING}"

aws eks update-kubeconfig \
	--name ${CLUSTER_NAME} \
	--alias "${CLUSTER_NAME}" \
	--region ${AWS_REGION} ${PROFILE_STRING}

kubectl config get-contexts