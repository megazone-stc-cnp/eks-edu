#!/bin/bash

. ../env.sh
# PROFILE_NAME=cnp-key
. ./local_env.sh
# VPC_CNI_ROLE_NAME=cliAmazonEKSVPCCNIRole
# ==============================================
aws iam detach-role-policy \
    --role-name ${VPC_CNI_ROLE_NAME} \
    --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy \
    --profile ${PROFILE_NAME}

aws iam delete-role \
    --role-name ${VPC_CNI_ROLE_NAME} \
    --profile ${PROFILE_NAME}

rm -rf vpc-cni-trust-policy.json    