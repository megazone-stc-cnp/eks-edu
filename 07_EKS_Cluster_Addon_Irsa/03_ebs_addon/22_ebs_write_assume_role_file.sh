#!/bin/bash

if [ ! -f "./local_env.sh" ];then
	echo "local_env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ./local_env.sh
# export OIDC_ID=0A7E9D9D443319C0B6469DEA0A371292

if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh

# ===============================================
cat >aws-ebs-csi-driver-trust-policy.json<<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${ACCOUNT_ID}:oidc-provider/oidc.eks.${REGION_NAME}.amazonaws.com/id/${OIDC_ID}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringLike": {
          "oidc.eks.${REGION_NAME}.amazonaws.com/id/${OIDC_ID}:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa",
          "oidc.eks.${REGION_NAME}.amazonaws.com/id/${OIDC_ID}:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
EOF

cat aws-ebs-csi-driver-trust-policy.json