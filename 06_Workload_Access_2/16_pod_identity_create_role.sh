#!/bin/bash

if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh

SERVICE_ACCOUNT_NAME=eks-edu-pod-identity-service-account-${EMPLOY_ID}
POLICY_NAME=eks-edu-pod-identity-workload-policy-${EMPLOY_ID}
ROLE_NAME=eks-edu-pod-identity-workload-role-${EMPLOY_ID}
NAMESPACE_NAME=default
# ==================================================================

cat >pod-identity-trust-relationship.json <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowEksAuthToAssumeRoleForPodIdentity",
            "Effect": "Allow",
            "Principal": {
                "Service": "pods.eks.amazonaws.com"
            },
            "Action": [
                "sts:AssumeRole",
                "sts:TagSession"
            ]
        }
    ]
}
EOF

echo "aws iam create-role \\
    --role-name ${ROLE_NAME} \\
    --assume-role-policy-document file://pod-identity-trust-relationship.json \\
    --description "${ROLE_NAME}-description" ${PROFILE_STRING}"

aws iam create-role \
    --role-name ${ROLE_NAME} \
    --assume-role-policy-document file://pod-identity-trust-relationship.json \
    --description "${ROLE_NAME}-description" ${PROFILE_STRING}

echo "aws iam attach-role-policy \\
    --role-name ${ROLE_NAME} \\
    --policy-arn=arn:aws:iam::${AWS_REPO_ACCOUNT}:policy/${POLICY_NAME} ${PROFILE_STRING}"

aws iam attach-role-policy \
    --role-name ${ROLE_NAME} \
    --policy-arn=arn:aws:iam::${AWS_REPO_ACCOUNT}:policy/${POLICY_NAME} ${PROFILE_STRING}