#!/bin/bash

if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

POLICY_NAME=eks-edu-user-policy-${IDE_NAME}
IAM_USER=eks-edu-user-${IDE_NAME}
# ==================================================================
if [ ! -d "tmp" ]; then
    mkdir -p tmp
fi

# Check if policy exists
EXISTING_POLICY=$(aws iam get-policy --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${POLICY_NAME} ${PROFILE_STRING} 2>/dev/null)

if [ ! -z "$EXISTING_POLICY" ]; then
    echo "Policy ${POLICY_NAME} 가 존재합니다."
    exit 0
fi

cat >tmp/eks-edu-user-policy.json <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "eks:DescribeCluster",
            "Resource": "*"
        }
    ]
}
EOF

echo "${POLICY_NAME} 생성중..."
# eks user policy 생성
echo "aws iam create-policy --policy-name ${POLICY_NAME} \\
	--policy-document file://tmp/eks-edu-user-policy.json ${PROFILE_STRING}"

aws iam create-policy --policy-name ${POLICY_NAME} \
	--policy-document file://tmp/eks-edu-user-policy.json ${PROFILE_STRING}

aws iam wait policy-exists \
    --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${POLICY_NAME} ${PROFILE_STRING}

# Attach policy to allow EKS access
echo "aws iam attach-user-policy \\
    --user-name ${IAM_USER} \\
    --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${POLICY_NAME} ${PROFILE_STRING}"

aws iam attach-user-policy \
    --user-name eks-edu-user-${IDE_NAME} \
    --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${POLICY_NAME} ${PROFILE_STRING}
echo "${POLICY_NAME} 생성완료..."