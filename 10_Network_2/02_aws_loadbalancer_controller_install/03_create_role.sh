#!/bin/bash
if [ ! -f "../../env.sh" ];then
    echo "env.sh 파일 세팅을 해주세요."
    exit 1
fi
. ../../env.sh
# export AWS_REGION=ap-northeast-1
# export EMPLOY_ID=9641173
# export PROFILE_NAME=cnp-key
# export AWS_REPO_ACCOUNT=539666729110
# export HOME_DIR=/Users/mzc01-hcseo/00_PARA/01_project/autoever-eks-edu/source/eks-edu
# export EKS_VERSION=1.31
# export CLUSTER_NAME=eks-edu-cluster-${EMPLOY_ID}
if [ ! -f "./local_env.sh" ];then
	echo "local_env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ./local_env.sh
# export OIDC_ID=

NAMESPACE_NAME=kube-system
SERVICE_ACCOUNT_NAME=alb-controller-sa
POLICY_NAME=eks-edu-aws-load-balancer-controller-policy-${EMPLOY_ID}
# ==================================================================
cat >tmp/trust-relationship.json <<EOF
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
    --assume-role-policy-document file://tmp/trust-relationship.json \\
    --description "${ROLE_NAME}-description" ${PROFILE_STRING}"

aws iam create-role \
    --role-name ${ROLE_NAME} \
    --assume-role-policy-document file://tmp/trust-relationship.json \
    --description "${ROLE_NAME}-description" ${PROFILE_STRING}

echo "aws iam attach-role-policy \\
    --role-name ${ROLE_NAME} \\
    --policy-arn=arn:aws:iam::${AWS_REPO_ACCOUNT}:policy/${POLICY_NAME} ${PROFILE_STRING}"

aws iam attach-role-policy \
    --role-name ${ROLE_NAME} \
    --policy-arn=arn:aws:iam::${AWS_REPO_ACCOUNT}:policy/${POLICY_NAME} ${PROFILE_STRING}