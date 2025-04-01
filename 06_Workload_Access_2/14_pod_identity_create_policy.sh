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

BUCKET_NAME="pod-secrets-bucket-${EMPLOY_ID}"
POLICY_NAME=eks-edu-pod-identity-workload-policy-${EMPLOY_ID}
# ==================================================================

cat >pod-identity-workload-policy.json <<EOF
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
    --policy-document file://pod-identity-workload-policy.json ${PROFILE_STRING}"

aws iam create-policy --policy-name ${POLICY_NAME} \
    --policy-document file://pod-identity-workload-policy.json ${PROFILE_STRING}