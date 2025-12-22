#!/bin/bash

if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

ARGOCD_CAPABILITY_ROLE_NAME=eks-edu-argocd-capability-role-${IDE_NAME}
# ==============================================================
# Check if IAM role already exists
echo "Checking if IAM role ${ARGOCD_CAPABILITY_ROLE_NAME} exists..."
if aws iam get-role --role-name ${ARGOCD_CAPABILITY_ROLE_NAME} ${PROFILE_STRING} >/dev/null 2>&1; then
    echo "IAM role ${ARGOCD_CAPABILITY_ROLE_NAME} already exists. Skipping role creation."
else
    echo "Creating IAM role ${ARGOCD_CAPABILITY_ROLE_NAME}..."
    echo "aws iam create-role \\
      --role-name ${ARGOCD_CAPABILITY_ROLE_NAME} \\
      --assume-role-policy-document file://tmp/argocd-trust-policy.json ${PROFILE_STRING}"
    echo ""

    aws iam create-role \
      --role-name ${ARGOCD_CAPABILITY_ROLE_NAME} \
      --assume-role-policy-document file://tmp/argocd-trust-policy.json ${PROFILE_STRING}

    aws iam wait role-exists --role-name ${ARGOCD_CAPABILITY_ROLE_NAME} ${PROFILE_STRING}
fi

# Check if SecretsManager policy is already attached
echo "Checking if AWSSecretsManagerClientReadOnlyAccess policy is attached..."
if aws iam list-attached-role-policies --role-name ${ARGOCD_CAPABILITY_ROLE_NAME} ${PROFILE_STRING} | grep -q "AWSSecretsManagerClientReadOnlyAccess"; then
    echo "AWSSecretsManagerClientReadOnlyAccess policy already attached. Skipping policy attachment."
else
    echo "Attaching AWSSecretsManagerClientReadOnlyAccess policy..."
    echo "aws iam attach-role-policy \\
        --policy-arn arn:aws:iam::aws:policy/AWSSecretsManagerClientReadOnlyAccess \\
        --role-name ${ARGOCD_CAPABILITY_ROLE_NAME} ${PROFILE_STRING}"
    echo ""

    aws iam attach-role-policy \
        --policy-arn arn:aws:iam::aws:policy/AWSSecretsManagerClientReadOnlyAccess \
        --role-name ${ARGOCD_CAPABILITY_ROLE_NAME} ${PROFILE_STRING}
fi

# Check if access entry already exists
echo "Checking if access entry for ${ARGOCD_CAPABILITY_ROLE_NAME} exists..."
if aws eks describe-access-entry --cluster-name ${CLUSTER_NAME} --principal-arn arn:aws:iam::${AWS_ACCOUNT_ID}:role/${ARGOCD_CAPABILITY_ROLE_NAME} ${PROFILE_STRING} >/dev/null 2>&1; then
    echo "Access entry for ${ARGOCD_CAPABILITY_ROLE_NAME} already exists. Skipping access entry creation."
else
    echo "Creating access entry for ${ARGOCD_CAPABILITY_ROLE_NAME}..."
    echo "aws eks create-access-entry \\
        --cluster-name ${CLUSTER_NAME} \\
        --principal-arn arn:aws:iam::${AWS_ACCOUNT_ID}:role/${ARGOCD_CAPABILITY_ROLE_NAME} \\
        --type STANDARD \\
        --username argocd-capability-role ${PROFILE_STRING}"
    echo ""

    aws eks create-access-entry \
        --cluster-name ${CLUSTER_NAME} \
        --principal-arn arn:aws:iam::${AWS_ACCOUNT_ID}:role/${ARGOCD_CAPABILITY_ROLE_NAME} \
        --type STANDARD \
        --username argocd-capability-role ${PROFILE_STRING}

    echo "Associating AmazonEKSClusterAdminPolicy..."
    echo "aws eks associate-access-policy \\
        --cluster-name ${CLUSTER_NAME} \\
        --principal-arn arn:aws:iam::${AWS_ACCOUNT_ID}:role/${ARGOCD_CAPABILITY_ROLE_NAME} \\
        --policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy \\
        --access-scope type=cluster ${PROFILE_STRING}"
    echo ""

    aws eks associate-access-policy \
        --cluster-name ${CLUSTER_NAME} \
        --principal-arn arn:aws:iam::${AWS_ACCOUNT_ID}:role/${ARGOCD_CAPABILITY_ROLE_NAME} \
        --policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy \
        --access-scope type=cluster ${PROFILE_STRING}

    echo "aws eks associate-access-policy \\
        --cluster-name ${CLUSTER_NAME} \\
        --principal-arn arn:aws:iam::${AWS_ACCOUNT_ID}:role/${ARGOCD_CAPABILITY_ROLE_NAME} \\
        --policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSArgoCDPolicy \\
        --access-scope type=cluster ${PROFILE_STRING}"
    echo ""

    aws eks associate-access-policy \
        --cluster-name ${CLUSTER_NAME} \
        --principal-arn arn:aws:iam::${AWS_ACCOUNT_ID}:role/${ARGOCD_CAPABILITY_ROLE_NAME} \
        --policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSArgoCDPolicy \
        --access-scope type=cluster ${PROFILE_STRING}
fi
