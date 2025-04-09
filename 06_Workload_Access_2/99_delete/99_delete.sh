#!/bin/bash

if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

BUCKET_NAME="pod-secrets-bucket-${IDE_NAME}"


IRSA_POLICY_NAME=eks-edu-irsa-workload-policy-${IDE_NAME}
IRSA_ROLE_NAME=eks-edu-irsa-workload-role-${IDE_NAME}

POD_IDENTITY_POLICY_NAME=eks-edu-pod-identity-workload-policy-${IDE_NAME}
POD_IDENTITY_ROLE_NAME=eks-edu-pod-identity-workload-role-${IDE_NAME}
# ================================================
IRSA_ROLE_TRUST_POLICY=$(aws iam list-role-policies --role-name ${IRSA_ROLE_NAME} --query 'PolicyNames[*]' --output text ${PROFILE_STRING} 2>/dev/null)
if [ ! -z "$IRSA_ROLE_TRUST_POLICY" ]; then
    for policy in $IRSA_ROLE_TRUST_POLICY; do
        echo "aws iam delete-role-policy \
                --role-name ${IRSA_ROLE_NAME} \
                --policy-name ${policy} ${PROFILE_STRING}"
        echo ""
        aws iam delete-role-policy \
                --role-name ${IRSA_ROLE_NAME} \
                --policy-name ${policy} ${PROFILE_STRING}
    done
fi

IRSA_ROLE_EXISTS=$(aws iam get-role --role-name ${IRSA_ROLE_NAME} ${PROFILE_STRING} >/dev/null 2>&1)
if [ $? -eq 0 ]; then
    # Check and delete trust relationship policy for IRSA role
    echo "aws iam delete-role \\
            --role-name ${IRSA_ROLE_NAME} ${PROFILE_STRING}"
    echo ""
    aws iam delete-role \
        --role-name ${IRSA_ROLE_NAME} ${PROFILE_STRING}    
fi

POD_IDENTITY_TRUST_POLICY=$(aws iam list-role-policies --role-name ${POD_IDENTITY_ROLE_NAME} --query 'PolicyNames[*]' --output text ${PROFILE_STRING} 2>/dev/null)

if [ ! -z "$POD_IDENTITY_TRUST_POLICY" ]; then
    for policy in $POD_IDENTITY_TRUST_POLICY; do
        echo "aws iam delete-role-policy \
                --role-name ${POD_IDENTITY_ROLE_NAME} \
                --policy-name ${policy} ${PROFILE_STRING}"
        echo ""
        aws iam delete-role-policy \
                --role-name ${POD_IDENTITY_ROLE_NAME} \
                --policy-name ${policy} ${PROFILE_STRING}
    done
fi

POD_IDENTITY_ROLE_EXISTS=$(aws iam get-role --role-name ${POD_IDENTITY_ROLE_NAME} ${PROFILE_STRING} >/dev/null 2>&1)
if [ $? -eq 0 ]; then
    echo "aws iam delete-role \\
            --role-name ${POD_IDENTITY_ROLE_NAME} ${PROFILE_STRING}"
    echo ""
    aws iam delete-role \
        --role-name ${POD_IDENTITY_ROLE_NAME} ${PROFILE_STRING}    
fi

if aws s3api head-bucket --bucket "${BUCKET_NAME}" 2>/dev/null; then
    # Delete all objects in the bucket first
    echo "aws s3 rm s3://${BUCKET_NAME} --recursive ${PROFILE_STRING}"
    aws s3 rm s3://${BUCKET_NAME} --recursive ${PROFILE_STRING}

    # Delete the bucket
    echo "aws s3 rb s3://${BUCKET_NAME} ${PROFILE_STRING}"
    aws s3 rb s3://${BUCKET_NAME} ${PROFILE_STRING}
fi
