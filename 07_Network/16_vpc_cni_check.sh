#!/bin/bash

. ../env.sh
# REGION_NAME=ap-northeast-1
# PROFILE_NAME=cnp-key
# EKS_CLUSTER_NAME=cli-cluster
# EKS_CLUSTER_VERSION=1.30
# ACCOUNT_ID=539666729110

. ./local_env.sh
# VPC_CNI_VERSION=v2.0.5-eksbuild.1
# VPC_CNI_ROLE_NAME=cliAmazonEKSVPCCNIRole
# ADDON_NAME=vpc-cni

# ================================
aws eks update-addon --cluster-name ${EKS_CLUSTER_NAME} \
    --addon-name ${ADDON_NAME} \
    --pod-identity-associations "serviceAccount=aws-node,roleArn=arn:aws:iam::${ACCOUNT_ID}:role/${VPC_CNI_ROLE_NAME}" \
    --profile ${PROFILE_NAME}
# aws eks describe-addon \
#     --cluster-name ${EKS_CLUSTER_NAME} \
#     --addon-name ${ADDON_NAME} \
#     --profile ${PROFILE_NAME} \
#     --region ${REGION_NAME}