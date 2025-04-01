#!/bin/bash

if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh
# export AWS_REGION=
# export EMPLOY_ID=
# export PROFILE_NAME=
# export AWS_REPO_ACCOUNT=
if [ ! -f "./local_env.sh" ];then
	echo "local_env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ./local_env.sh
# export OIDC_ID=

SERVICE_ACCOUNT_NAME=eks-edu-service-account-${EMPLOY_ID}
POLICY_NAME=eks-edu-workload-policy-${EMPLOY_ID}
ROLE_NAME=eks-edu-workload-role-${EMPLOY_ID}
NAMESPACE_NAME=default
# ==================================================================

cat >trust-relationship.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${AWS_REPO_ACCOUNT}:oidc-provider/${OIDC_ID}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${OIDC_ID}:aud": "sts.amazonaws.com",
          "${OIDC_ID}:sub": "system:serviceaccount:${NAMESPACE_NAME}:${SERVICE_ACCOUNT_NAME}"
        }
      }
    }
  ]
}
EOF

echo "aws iam create-role \\
    --role-name ${ROLE_NAME} \\
    --assume-role-policy-document file://trust-relationship.json \\
    --description "${ROLE_NAME}-description" ${PROFILE_STRING}"

aws iam create-role \
    --role-name ${ROLE_NAME} \
    --assume-role-policy-document file://trust-relationship.json \
    --description "${ROLE_NAME}-description" ${PROFILE_STRING}

echo "aws iam attach-role-policy \\
    --role-name ${ROLE_NAME} \\
    --policy-arn=arn:aws:iam::${AWS_REPO_ACCOUNT}:policy/${POLICY_NAME} ${PROFILE_STRING}"

aws iam attach-role-policy \
    --role-name ${ROLE_NAME} \
    --policy-arn=arn:aws:iam::${AWS_REPO_ACCOUNT}:policy/${POLICY_NAME} ${PROFILE_STRING}