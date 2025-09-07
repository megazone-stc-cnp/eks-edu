#!/bin/bash

if [ ! -f "../../env.sh" ];then
  echo "env.sh 파일 세팅을 해주세요."
  exit 1
fi
. ../../env.sh

if [ ! -f "../upgrade_env.sh" ];then
  echo "upgrade_env.sh 파일 세팅을 해주세요."
  exit 1
fi
. ../upgrade_env.sh

# ==============================================================
echo "aws eks list-insights  \\
      	--cluster-name ${CLUSTER_NAME} \\
      	--filter kubernetesVersions=${EKS_UPGRADE_CLUSTER_VERSION} \\
      	--region ${AWS_REGION} ${PROFILE_STRING} \\
      	--no-paginate \\
      	--output json"

aws eks list-insights  \
	--cluster-name ${CLUSTER_NAME} \
	--filter kubernetesVersions=${EKS_UPGRADE_CLUSTER_VERSION} \
	--region ${AWS_REGION} ${PROFILE_STRING} \
	--no-paginate \
	--output json 
