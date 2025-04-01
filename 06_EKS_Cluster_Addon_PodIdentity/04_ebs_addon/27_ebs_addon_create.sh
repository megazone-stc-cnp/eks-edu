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
# export AWS_REGION=ap-northeast-1
# export EMPLOY_ID=9641173
# export PROFILE_NAME=cnp-key
# export AWS_REPO_ACCOUNT=539666729110
# export HOME_DIR=/Users/mzc01-hcseo/00_PARA/01_project/autoever-eks-edu/source/eks-edu
# export EKS_VERSION=1.31
# export CLUSTER_NAME=eks-edu-cluster-${EMPLOY_ID}

ADDON_NAME=aws-ebs-csi-driver
EBS_ROLE_NAME=eks-edu-ebs-pod-identity-role-${EMPLOY_ID}
# ===============================================
echo "aws eks create-addon \\
    --cluster-name ${CLUSTER_NAME} \\
    --addon-name ${ADDON_NAME} \\
    --addon-version ${ADDON_VERSION} \\
    --pod-identity-associations "serviceAccount=ebs-csi-controller-sa,roleArn=arn:aws:iam::${AWS_REPO_ACCOUNT}:role/${EBS_ROLE_NAME}" \\
    --resolve-conflicts OVERWRITE \\
    --region ${AWS_REGION} ${PROFILE_STRING}"

aws eks create-addon \
    --cluster-name ${CLUSTER_NAME} \
    --addon-name ${ADDON_NAME} \
    --addon-version ${ADDON_VERSION} \
    --pod-identity-associations "serviceAccount=ebs-csi-controller-sa,roleArn=arn:aws:iam::${AWS_REPO_ACCOUNT}:role/${EBS_ROLE_NAME}" \
    --resolve-conflicts OVERWRITE \
    --region ${AWS_REGION} ${PROFILE_STRING}


echo "EBS ADDON 생성중..."
echo "aws eks wait addon-active \\
    --cluster-name ${CLUSTER_NAME} \\
    --addon-name ${ADDON_NAME} \\
    --region ${AWS_REGION} ${PROFILE_STRING}"

aws eks wait addon-active \
    --cluster-name ${CLUSTER_NAME} \
    --addon-name ${ADDON_NAME} \
    --region ${AWS_REGION} ${PROFILE_STRING}

echo "EBS ADDON 생성완료..."    