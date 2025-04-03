#!/bin/bash
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

ADDON_NAME=aws-efs-csi-driver
EFS_ROLE_NAME=eks-edu-efs-irsa-role-${IDE_NAME}
# ===============================================
echo "aws eks create-addon \\
    --cluster-name ${CLUSTER_NAME} \\
    --addon-name ${ADDON_NAME} \\
    --addon-version ${ADDON_VERSION} \\
    --service-account-role-arn arn:aws:iam::${AWS_ACCOUNT_ID}:role/${EFS_ROLE_NAME} \\
    --resolve-conflicts OVERWRITE ${PROFILE_STRING}"

aws eks create-addon \
    --cluster-name ${CLUSTER_NAME} \
    --addon-name ${ADDON_NAME} \
    --addon-version ${ADDON_VERSION} \
    --service-account-role-arn arn:aws:iam::${AWS_ACCOUNT_ID}:role/${EFS_ROLE_NAME} \
    --resolve-conflicts OVERWRITE ${PROFILE_STRING}


echo "EFS ADDON 생성중..."
echo "aws eks wait addon-active \\
    --cluster-name ${CLUSTER_NAME} \\
    --addon-name ${ADDON_NAME} ${PROFILE_STRING}"

aws eks wait addon-active \
    --cluster-name ${CLUSTER_NAME} \
    --addon-name ${ADDON_NAME} ${PROFILE_STRING}

echo "EFS ADDON 생성완료..."    