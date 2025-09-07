#!/bin/bash

if [ ! -f "../../env.sh" ];then
  echo "env.sh 파일 세팅을 해주세요."
  exit 1
fi
. ../../env.sh

# ==============================================================
aws eks list-insights  \
	--cluster-name ${EKS_CLUSTER_NAME} \
	--filter kubernetesVersions=${EKS_UPGRADE_CLUSTER_VERSION} \
	--region ${AWS_REGION} ${PROFILE_STRING} \
	--no-paginate \
	--output json 
