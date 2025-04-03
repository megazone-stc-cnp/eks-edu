#!/bin/bash
#
if [ -z "$1" ]; then
    echo "사용법: $0 <ADDON_VERSION>"
    exit 1
fi
ADDON_VERSION=$1

if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh

ADDON_NAME=kube-proxy
# ============================================================
aws eks describe-addon-configuration \
    --addon-name ${ADDON_NAME} \
    --addon-version ${ADDON_VERSION} ${PROFILE_STRING}