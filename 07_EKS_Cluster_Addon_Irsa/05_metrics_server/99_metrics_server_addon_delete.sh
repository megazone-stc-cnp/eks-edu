#!/bin/bash
if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh

ADDON_NAME=metrics-server
# ==============================================
echo "aws eks delete-addon \\
    --cluster-name ${CLUSTER_NAME} \\
    --addon-name ${ADDON_NAME} ${PROFILE_STRING}"