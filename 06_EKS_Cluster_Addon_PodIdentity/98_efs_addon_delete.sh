#!/bin/bash

. ../env.sh
# PROFILE_NAME=cnp-key
. ./local_env.sh
# EFS_ROLE_NAME=cliAmazonEKSEBSCNIRole
# ==============================================
aws iam detach-role-policy \
    --role-name ${EFS_ROLE_NAME} \
    --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy \
    --profile ${PROFILE_NAME}

aws iam delete-role \
    --role-name ${EFS_ROLE_NAME} \
    --profile ${PROFILE_NAME}