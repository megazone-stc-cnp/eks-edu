#!/bin/bash
if [ ! -f "../env.sh" ];then
	echo "Root 디렉토리에 env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh
# ======================================================
eksctl delete cluster --name eks-edu-cluster-${EMPLOY_ID} --region ${AWS_REGION}