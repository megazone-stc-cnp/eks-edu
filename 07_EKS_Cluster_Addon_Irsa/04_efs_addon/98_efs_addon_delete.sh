#!/bin/bash
if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh
# export AWS_REGION=ap-northeast-1
# export IDE_NAME=9641173
# export PROFILE_NAME=cnp-key
# export AWS_REPO_ACCOUNT=539666729110
# export HOME_DIR=/Users/mzc01-hcseo/00_PARA/01_project/autoever-eks-edu/source/eks-edu
# export EKS_VERSION=1.31
# export CLUSTER_NAME=eks-edu-cluster-${IDE_NAME}

ADDON_NAME=aws-efs-csi-driver
EFS_ROLE_NAME=eks-edu-efs-irsa-role-${IDE_NAME}
# ==============================================
echo "Deleting ${ADDON_NAME} addon from EKS cluster ${CLUSTER_NAME}..."

echo "aws eks delete-addon \\
    --cluster-name ${CLUSTER_NAME} \\
    --addon-name ${ADDON_NAME} ${PROFILE_STRING}"

# Delete the CoreDNS addon
aws eks delete-addon \
    --cluster-name ${CLUSTER_NAME} \
    --addon-name ${ADDON_NAME} ${PROFILE_STRING}

echo "${ADDON_NAME} addon deleted successfully."

echo "aws iam detach-role-policy \\
    --role-name ${EFS_ROLE_NAME} \\
    --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy ${PROFILE_STRING}"

aws iam detach-role-policy \
    --role-name ${EFS_ROLE_NAME} \
    --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy ${PROFILE_STRING}

echo "aws iam delete-role \\
    --role-name ${EFS_ROLE_NAME} ${PROFILE_STRING}"

aws iam delete-role \
    --role-name ${EFS_ROLE_NAME} ${PROFILE_STRING}







