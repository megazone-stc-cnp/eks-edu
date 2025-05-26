#!/bin/bash

if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

POLICY_NAME="mount-point-for-amazon-policy-${IDE_NAME}"
BUCKET_NAME="mount-point-for-amazon-s3-bucket-${IDE_NAME}"
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

cat >tmp/mount-point-for-amazon-policy.json <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
        {
            "Sid": "MountpointFullBucketAccess",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::${BUCKET_NAME}"
            ]
        },
        {
            "Sid": "MountpointFullObjectAccess",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:AbortMultipartUpload",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::${BUCKET_NAME}/*"
            ]
        }
   ]
}
EOF

echo "${POLICY_NAME} 생성중..."
# eks user policy 생성
echo "aws iam create-policy --policy-name ${POLICY_NAME} \\
	--policy-document file://tmp/eks-edu-user-policy.json ${PROFILE_STRING}"

aws iam create-policy --policy-name ${POLICY_NAME} \
	--policy-document file://tmp/mount-point-for-amazon-policy.json ${PROFILE_STRING}

aws iam wait policy-exists \
    --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${POLICY_NAME} ${PROFILE_STRING}

echo "${POLICY_NAME} 생성완료..."