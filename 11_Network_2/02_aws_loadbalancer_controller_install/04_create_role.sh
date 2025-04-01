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
ROLE_NAME=eks-edu-aws-load-balancer-controller-role-${EMPLOY_ID}
# ==================================================================
cat >tmp/trust-relationship.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${AWS_REPO_ACCOUNT}:oidc-provider/oidc.eks.${AWS_REGION}.amazonaws.com/id/${OIDC_ID}"
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

# Check if the role already exists
ROLE_EXISTS=$(aws iam get-role --role-name ${ROLE_NAME} ${PROFILE_STRING} 2>&1 || echo "ROLE_NOT_FOUND")

if [[ ! "$ROLE_EXISTS" == *"ROLE_NOT_FOUND"* ]]; then
    echo "Error: ${ROLE_NAME} 이 존재합니다. 삭제를 진행하고 다시 진행해 주세요."
    exit 1
fi

echo "aws iam create-role \\
    --role-name ${ROLE_NAME} \\
    --assume-role-policy-document file://tmp/trust-relationship.json \\
    --description "${ROLE_NAME}-description" ${PROFILE_STRING}"

echo "${ROLE_NAME} 생성중..."
aws iam create-role \
    --role-name ${ROLE_NAME} \
    --assume-role-policy-document file://tmp/trust-relationship.json \
    --description "${ROLE_NAME}-description" ${PROFILE_STRING}

echo "aws iam wait role-exists \\
    --role-name ${ROLE_NAME} ${PROFILE_STRING}"

aws iam wait role-exists \
    --role-name ${ROLE_NAME} ${PROFILE_STRING}

echo "aws iam attach-role-policy \\
    --role-name ${ROLE_NAME} \\
    --policy-arn=arn:aws:iam::${AWS_REPO_ACCOUNT}:policy/${POLICY_NAME} ${PROFILE_STRING}"

aws iam attach-role-policy \
    --role-name ${ROLE_NAME} \
    --policy-arn=arn:aws:iam::${AWS_REPO_ACCOUNT}:policy/${POLICY_NAME} ${PROFILE_STRING}
echo "${ROLE_NAME} 완료..."    