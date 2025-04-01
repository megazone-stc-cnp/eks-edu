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
# export CLUSTER_NAME=eks-edu-cluster-${EMPLOY_ID}

BUCKET_NAME="pod-secrets-bucket-${EMPLOY_ID}"
# ==================================================================

if aws s3api head-bucket --bucket "${BUCKET_NAME}" 2>/dev/null; then
    echo "S3 버킷 ${BUCKET_NAME}이 이미 존재합니다."
else
    echo "S3 버킷 ${BUCKET_NAME}이 존재하지 않습니다. 생성 중..."
    
    # us-east-1은 create-bucket 시 --create-bucket-configuration 옵션이 필요 없음
    if [ "$AWS_REGION" == "us-east-1" ]; then
        aws s3api create-bucket --bucket "${BUCKET_NAME}"
    else
        aws s3api create-bucket --bucket "${BUCKET_NAME}" --region "${AWS_REGION}" \
            --create-bucket-configuration LocationConstraint="${AWS_REGION}"
    fi

    echo "S3 버킷 ${BUCKET_NAME}이 성공적으로 생성되었습니다!"
fi