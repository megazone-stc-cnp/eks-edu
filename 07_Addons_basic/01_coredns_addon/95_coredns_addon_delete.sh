#!/bin/bash

if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

set -x
ADDON_NAME=coredns
# ============================================================
set +x
echo "Deleting CoreDNS addon from EKS cluster ${CLUSTER_NAME}..."
set -x

# Delete the CoreDNS addon
aws eks delete-addon \
    --cluster-name ${CLUSTER_NAME} \
    --addon-name ${ADDON_NAME} ${PROFILE_STRING}

set +x
echo "CoreDNS addon deleted successfully."
