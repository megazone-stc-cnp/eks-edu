#!/bin/bash

if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh

# ==================================================================

oidc_id=$(aws eks describe-cluster --name ${CLUSTER_NAME} --query "cluster.identity.oidc.issuer" --output text ${PROFILE_STRING} | cut -d '/' -f 5)

echo "OIDC ID : ${oidc_id}"
echo "이 값을 local_env.sh에 세팅해야 한다. !!"