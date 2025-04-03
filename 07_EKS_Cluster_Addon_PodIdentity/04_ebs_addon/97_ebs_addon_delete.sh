#!/bin/bash
if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh

ADDON_NAME=aws-ebs-csi-driver
EBS_ROLE_NAME=eks-edu-ebs-pod-identity-role-${IDE_NAME}
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
    --role-name ${EBS_ROLE_NAME} \\
    --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy ${PROFILE_STRING}"

aws iam detach-role-policy \
    --role-name ${EBS_ROLE_NAME} \
    --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy ${PROFILE_STRING}

echo "aws iam delete-role \\
    --role-name ${EBS_ROLE_NAME} ${PROFILE_STRING}"

aws iam delete-role \
    --role-name ${EBS_ROLE_NAME} ${PROFILE_STRING}







