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
IRSA_ROLE_EXISTS=$(aws iam get-role --role-name ${IRSA_ROLE_NAME} ${PROFILE_STRING} 2>&1 || echo "ROLE_NOT_FOUND")
if [[ ! "$IRSA_ROLE_EXISTS" == *"ROLE_NOT_FOUND"* ]]; then
    IRSA_POLICIES=$(aws iam list-attached-role-policies --role-name "$IRSA_ROLE_NAME" --query 'AttachedPolicies[].PolicyArn' --output text ${PROFILE_STRING})

    for POLICY_ARN in $IRSA_POLICIES; do
        echo "aws iam detach-role-policy --role-name $IRSA_ROLE_NAME --policy-arn $POLICY_ARN ${PROFILE_STRING}"
        aws iam detach-role-policy --role-name "$IRSA_ROLE_NAME" --policy-arn "$POLICY_ARN" ${PROFILE_STRING}
    done

    IRSA_INLINE_POLICIES=$(aws iam list-role-policies --role-name "$IRSA_ROLE_NAME" --query 'PolicyNames[]' --output text ${PROFILE_STRING})

    for POLICY_NAME in $IRSA_INLINE_POLICIES; do
      echo "aws iam delete-role-policy --role-name $IRSA_ROLE_NAME --policy-name $POLICY_NAME ${PROFILE_STRING}"
      aws iam delete-role-policy --role-name "$IRSA_ROLE_NAME" --policy-name "$POLICY_NAME" ${PROFILE_STRING}
    done

	echo "aws iam delete-role --role-name $IRSA_ROLE_NAME ${PROFILE_STRING}"
	aws iam delete-role --role-name $IRSA_ROLE_NAME ${PROFILE_STRING}
fi

POD_IDENTITY_ROLE_EXISTS=$(aws iam get-role --role-name ${POD_IDENTITY_ROLE_NAME} ${PROFILE_STRING} 2>&1 || echo "ROLE_NOT_FOUND")
if [[ ! "$POD_IDENTITY_ROLE_EXISTS" == *"ROLE_NOT_FOUND"* ]]; then

    POD_IDENTITY_POLICIES=$(aws iam list-attached-role-policies --role-name "$POD_IDENTITY_ROLE_NAME" --query 'AttachedPolicies[].PolicyArn' --output text ${PROFILE_STRING})

    for POLICY_ARN in $POD_IDENTITY_POLICIES; do
      echo "aws iam detach-role-policy --role-name $POD_IDENTITY_ROLE_NAME --policy-arn $POLICY_ARN ${PROFILE_STRING}"
      aws iam detach-role-policy --role-name "$POD_IDENTITY_ROLE_NAME" --policy-arn "$POLICY_ARN" ${PROFILE_STRING}
    done

    POD_IDENTITY_INLINE_POLICIES=$(aws iam list-role-policies --role-name "$POD_IDENTITY_ROLE_NAME" --query 'PolicyNames[]' --output text ${PROFILE_STRING})

    for POLICY_NAME in $POD_IDENTITY_INLINE_POLICIES; do
      echo "aws iam delete-role-policy --role-name $POD_IDENTITY_ROLE_NAME --policy-name $POLICY_NAME ${PROFILE_STRING}"
      aws iam delete-role-policy --role-name "$POD_IDENTITY_ROLE_NAME" --policy-name "$POLICY_NAME" ${PROFILE_STRING}
    done

	echo "aws iam delete-role --role-name $POD_IDENTITY_ROLE_NAME ${PROFILE_STRING}"
	aws iam delete-role --role-name $POD_IDENTITY_ROLE_NAME ${PROFILE_STRING}
fi

if aws s3api head-bucket --bucket "${BUCKET_NAME}" 2>/dev/null; then
    # Delete all objects in the bucket first
    echo "aws s3 rm s3://${BUCKET_NAME} --recursive ${PROFILE_STRING}"
    aws s3 rm s3://${BUCKET_NAME} --recursive ${PROFILE_STRING}

    # Delete the bucket
    echo "aws s3 rb s3://${BUCKET_NAME} ${PROFILE_STRING}"
    aws s3 rb s3://${BUCKET_NAME} ${PROFILE_STRING}
fi
