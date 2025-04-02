#!/bin/bash

if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh

CLUSTER_NAME=eks-edu-cluster-${IDE_NAME}
BUCKET_NAME="pod-secrets-bucket-${IDE_NAME}"
# ==================================================================

POLICY_NAME=eks-edu-irsa-workload-policy-${IDE_NAME}
cat >irsa-workload-policy.json <<EOF
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
    --policy-document file://irsa-workload-policy.json ${PROFILE_STRING}"

aws iam create-policy --policy-name ${POLICY_NAME} \
    --policy-document file://irsa-workload-policy.json ${PROFILE_STRING}