#!/bin/bash

if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh

CLUSTER_NAME=eks-edu-cluster-${EMPLOY_ID}
# ==================================================================
PROFILE_STRING=""
if [ -n "$PROFILE_NAME" ]; then
    PROFILE_STRING="--profile ${PROFILE_NAME}"
fi

cat >eks-edu-user-policy.json <<EOF
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

# eks user policy 생성
echo "aws iam create-policy --policy-name eks-edu-user-policy-${EMPLOY_ID} \
	--policy-document file://eks-edu-user-policy.json ${PROFILE_STRING}"

aws iam create-policy --policy-name eks-edu-user-policy-${EMPLOY_ID} \
	--policy-document file://eks-edu-user-policy.json ${PROFILE_STRING}

# Attach policy to allow EKS access
echo "aws iam attach-user-policy \
    --user-name eks-edu-user-${EMPLOY_ID} \
    --policy-arn arn:aws:iam::${AWS_REPO_ACCOUNT}:policy/eks-edu-user-policy-${EMPLOY_ID} ${PROFILE_STRING}"

aws iam attach-user-policy \
    --user-name eks-edu-user-${EMPLOY_ID} \
    --policy-arn arn:aws:iam::${AWS_REPO_ACCOUNT}:policy/eks-edu-user-policy-${EMPLOY_ID} ${PROFILE_STRING}
