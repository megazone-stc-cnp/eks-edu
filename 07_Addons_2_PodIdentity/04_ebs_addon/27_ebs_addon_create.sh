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

ADDON_NAME=aws-ebs-csi-driver
EBS_ROLE_NAME=eks-edu-ebs-pod-identity-role-${IDE_NAME}
# ===============================================
echo "aws eks create-addon \\
    --cluster-name ${CLUSTER_NAME} \\
    --addon-name ${ADDON_NAME} \\
    --addon-version ${ADDON_VERSION} \\
    --pod-identity-associations "serviceAccount=ebs-csi-controller-sa,roleArn=arn:aws:iam::${AWS_ACCOUNT_ID}:role/${EBS_ROLE_NAME}" \\
    --resolve-conflicts OVERWRITE ${PROFILE_STRING}"

aws eks create-addon \
    --cluster-name ${CLUSTER_NAME} \
    --addon-name ${ADDON_NAME} \
    --addon-version ${ADDON_VERSION} \
    --pod-identity-associations "serviceAccount=ebs-csi-controller-sa,roleArn=arn:aws:iam::${AWS_ACCOUNT_ID}:role/${EBS_ROLE_NAME}" \
    --resolve-conflicts OVERWRITE ${PROFILE_STRING}


echo "EBS ADDON 생성중..."
echo "aws eks wait addon-active \\
    --cluster-name ${CLUSTER_NAME} \\
    --addon-name ${ADDON_NAME} ${PROFILE_STRING}"

aws eks wait addon-active \
    --cluster-name ${CLUSTER_NAME} \
    --addon-name ${ADDON_NAME} ${PROFILE_STRING}

echo "EBS ADDON 생성완료..."    