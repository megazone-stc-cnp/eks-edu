#!/bin/bash

if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

if [ ! -f "./local_env.sh" ];then
	OIDC_ID=$(aws eks describe-cluster --name ${CLUSTER_NAME} --query "cluster.identity.oidc.issuer" --output text ${PROFILE_STRING} | cut -d '/' -f 5)
fi

SERVICE_ACCOUNT_NAME=eks-edu-service-account-${IDE_NAME}
POLICY_NAME=eks-edu-workload-policy-${IDE_NAME}
ROLE_NAME=eks-edu-workload-role-${IDE_NAME}
NAMESPACE_NAME=default
# ==================================================================
if [ ! -d "tmp" ]; then
    mkdir -p tmp
fi

cat >tmp/trust-relationship.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${AWS_ACCOUNT_ID}:oidc-provider/oidc.eks.${REGION_NAME}.amazonaws.com/id/${OIDC_ID}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "oidc.eks.${AWS_REGION}.amazonaws.com/id/${OIDC_ID}:aud": "sts.amazonaws.com",
          "oidc.eks.${AWS_REGION}.amazonaws.com/id/${OIDC_ID}:sub": "system:serviceaccount:${NAMESPACE_NAME}:${SERVICE_ACCOUNT_NAME}"
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
    --policy-arn=arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${POLICY_NAME} ${PROFILE_STRING}"

aws iam attach-role-policy \
    --role-name ${ROLE_NAME} \
    --policy-arn=arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${POLICY_NAME} ${PROFILE_STRING}