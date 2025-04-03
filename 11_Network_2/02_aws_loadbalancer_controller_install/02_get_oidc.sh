#!/bin/bash

if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

# ==================================================================

OIDC_ID=$(aws eks describe-cluster --name ${CLUSTER_NAME} --query "cluster.identity.oidc.issuer" --output text  ${PROFILE_STRING} | cut -d '/' -f 5)

if [ -f "./local_env.sh" ];then
    rm -rf local_env.sh
fi
echo "#!/bin/bash" >> local_env.sh
echo "export OIDC_ID=${OIDC_ID}" >> local_env.sh