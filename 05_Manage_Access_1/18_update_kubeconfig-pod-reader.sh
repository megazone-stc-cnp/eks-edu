#!/bin/bash


if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh

CLUSTER_NAME=eks-edu-cluster-${EMPLOY_ID}
# ==================================================================
PROFILE_NAME=eks-edu-profile-${EMPLOY_ID}


echo "aws eks update-kubeconfig \\
	--name ${CLUSTER_NAME} \\
	--alias "pod-reader" \\
	${AWS_REGION} --profile ${PROFILE_NAME}"

aws eks update-kubeconfig \
	--name ${CLUSTER_NAME} \
	--alias "pod-reader" \
	--region ${AWS_REGION} --profile ${PROFILE_NAME}

kubectl config get-contexts