#!/bin/bash

if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

NAMESPACE_NAME=argocd
WEB_URL=http://gitea.cnp.mzcstc.com/hcseo/test.git
USER_NAME=hcseo
PASSWORD_NAME=admin123!
# =====================================

argocd repo add ${WEB_URL} --username ${USER_NAME} --password ${PASSWORD_NAME} --insecure-skip-server-verification
