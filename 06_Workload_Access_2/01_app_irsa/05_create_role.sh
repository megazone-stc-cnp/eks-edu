#!/bin/bash

if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

if [ ! -f "./local_env.sh" ];then
	OIDC_ID=$(aws eks describe-cluster --name ${CLUSTER_NAME} --query "cluster.identity.oidc.issuer" --output text ${PROFILE_STRING} | cut -d '/' -f 5)
else
  . ./local_env.sh
fi

SERVICE_ACCOUNT_NAME=eks-edu-service-account-${IDE_NAME}
POLICY_NAME=eks-edu-workload-policy-${IDE_NAME}
ROLE_NAME=eks-edu-workload-role-${IDE_NAME}
NAMESPACE_NAME=default
# ==================================================================
if [ ! -d "tmp" ]; then
    mkdir -p tmp
fi

# Check if role exists
ROLE_EXISTS=$(aws iam get-role --role-name ${ROLE_NAME} ${PROFILE_STRING} 2>&1 || echo "ROLE_NOT_FOUND")

if [[ ! "$ROLE_EXISTS" == *"ROLE_NOT_FOUND"* ]]; then
    echo "Role ${ROLE_NAME} 이 존재합니다."
    exit 1
fi

cat >tmp/trust-relationship.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${AWS_ACCOUNT_ID}:oidc-provider/oidc.eks.${AWS_REGION}.amazonaws.com/id/${OIDC_ID}"
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
    --assume-role-policy-document file://tmp/trust-relationship.json \\
    --description "${ROLE_NAME}-description" ${PROFILE_STRING}"

echo "${ROLE_NAME} 생성중..."
aws iam create-role \
    --role-name ${ROLE_NAME} \
    --assume-role-policy-document file://tmp/trust-relationship.json \
    --description "${ROLE_NAME}-description" ${PROFILE_STRING}

echo "aws iam attach-role-policy \\
    --role-name ${ROLE_NAME} \\
    --policy-arn=arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${POLICY_NAME} ${PROFILE_STRING}"

aws iam attach-role-policy \
    --role-name ${ROLE_NAME} \
    --policy-arn=arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${POLICY_NAME} ${PROFILE_STRING}
echo "${ROLE_NAME} 생성 완료..."