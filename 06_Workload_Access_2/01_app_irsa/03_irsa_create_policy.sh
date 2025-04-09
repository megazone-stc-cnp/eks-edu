#!/bin/bash

if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

BUCKET_NAME=pod-secrets-bucket-${IDE_NAME}
POLICY_NAME=eks-edu-irsa-workload-policy-${IDE_NAME}
# ==================================================================
if [ ! -d "tmp" ]; then
    mkdir -p tmp
fi

# Check if policy already exists
POLICY_EXISTS=$(aws iam list-policies --query "Policies[?PolicyName=='${POLICY_NAME}'].Arn" --output text ${PROFILE_STRING})

if [ ! -z "$POLICY_EXISTS" ]; then
    echo "${POLICY_NAME} policy 가 존재합니다."
    exit 0
fi
cat >tmp/irsa-workload-policy.json <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${BUCKET_NAME}"
        }
    ]
}
EOF

echo "aws iam create-policy --policy-name ${POLICY_NAME} \\
    --policy-document file://tmp/irsa-workload-policy.json ${PROFILE_STRING}"

echo "${POLICY_NAME} 생성중"
aws iam create-policy --policy-name ${POLICY_NAME} \
    --policy-document file://tmp/irsa-workload-policy.json ${PROFILE_STRING}

aws iam wait policy-exists \
    --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${POLICY_NAME} ${PROFILE_STRING}
echo "${POLICY_NAME} 생성 완료"    