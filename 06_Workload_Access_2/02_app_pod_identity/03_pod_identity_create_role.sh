#!/bin/bash

if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

SERVICE_ACCOUNT_NAME=eks-edu-pod-identity-service-account-${IDE_NAME}
POLICY_NAME=eks-edu-pod-identity-workload-policy-${IDE_NAME}
ROLE_NAME=eks-edu-pod-identity-workload-role-${IDE_NAME}
NAMESPACE_NAME=default
# ==================================================================
if [ ! -d "tmp" ]; then
    mkdir -p tmp
fi

cat >tmp/pod-identity-trust-relationship.json <<EOF
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

# Check if role exists
aws iam get-role --role-name ${ROLE_NAME} ${PROFILE_STRING} >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "Role ${ROLE_NAME} 이 존재합니다."
    exit 1
fi

echo "aws iam create-role \\
    --role-name ${ROLE_NAME} \\
    --assume-role-policy-document file://tmp/pod-identity-trust-relationship.json \\
    --description "${ROLE_NAME}-description" ${PROFILE_STRING}"
echo ""

echo "${ROLE_NAME} 생성중..."
aws iam create-role \
    --role-name ${ROLE_NAME} \
    --assume-role-policy-document file://tmp/pod-identity-trust-relationship.json \
    --description "${ROLE_NAME}-description" ${PROFILE_STRING}

echo "aws iam attach-role-policy \\
    --role-name ${ROLE_NAME} \\
    --policy-arn=arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${POLICY_NAME} ${PROFILE_STRING}"
echo ""

aws iam attach-role-policy \
    --role-name ${ROLE_NAME} \
    --policy-arn=arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${POLICY_NAME} ${PROFILE_STRING}
echo "${ROLE_NAME} 생성 완료..."