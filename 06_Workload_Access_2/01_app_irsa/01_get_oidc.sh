#!/bin/bash

if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

LOCAL_ENV_FILE_PATH=tmp/local_env.sh
# ==================================================================
if [ ! -d "tmp" ]; then
    mkdir -p tmp
fi

OIDC_ID=$(aws eks describe-cluster --name ${CLUSTER_NAME} --query "cluster.identity.oidc.issuer" --output text ${PROFILE_STRING} | cut -d '/' -f 5)

echo "OIDC ID : ${OIDC_ID}"

if [ -f "${LOCAL_ENV_FILE_PATH}" ];then
    rm -rf ${LOCAL_ENV_FILE_PATH}
fi
echo "#!/bin/bash" >> ${LOCAL_ENV_FILE_PATH}
echo "export OIDC_ID=${OIDC_ID}" >> ${LOCAL_ENV_FILE_PATH}