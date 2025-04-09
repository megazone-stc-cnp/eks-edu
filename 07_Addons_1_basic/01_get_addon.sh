#!/bin/bash

if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi

. ../env.sh

# ==============================================================

aws eks describe-addon-versions --kubernetes-version ${EKS_VERSION} \
    --query 'addons[].{MarketplaceProductUrl: marketplaceInformation.productUrl, Name: addonName, Owner: owner Publisher: publisher, Type: type}' \
    --output table ${PROFILE_STRING}
    
