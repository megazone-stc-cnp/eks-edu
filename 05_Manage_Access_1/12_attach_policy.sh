#!/bin/bash

if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh
# export AWS_REGION=ap-northeast-1
# export EMPLOY_ID=9641173
# export PROFILE_NAME=cnp-key
# export AWS_REPO_ACCOUNT=539666729110
# export HOME_DIR=/Users/mzc01-hcseo/00_PARA/01_project/autoever-eks-edu/source/eks-edu
# export EKS_VERSION=1.31
# export CLUSTER_NAME=eks-edu-cluster-${EMPLOY_ID}
# ==================================================================

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
