#!/bin/bash

if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

if ! command -v docker &> /dev/null; then
    echo "[ERROR] docker가 설치되어 있지 않습니다."
    exit 1
fi
# AWS_REPO_ACCOUNT=539666729110
REPOSITORY_PREFIX=public-ecr-${IDE_NAME}
# ==================================================================
# ECR 리포지토리 삭제
echo "ECR 리포지토리 삭제를 시작합니다..."

# 1. Pull Through Cache Rule 삭제
echo "Pull Through Cache Rule 삭제 중..."
echo "aws ecr delete-pull-through-cache-rule \\
    --ecr-repository-prefix ${REPOSITORY_PREFIX} ${PROFILE_STRING}"

aws ecr delete-pull-through-cache-rule \
    --ecr-repository-prefix ${REPOSITORY_PREFIX} ${PROFILE_STRING}

# 2. ECR 리포지토리 목록 조회 및 삭제
# ECR 리포지토리 삭제 함수
delete_ecr_repository() {
    local repo=$1
    echo "리포지토리 $repo 삭제 중..."
    
    # 이미지 목록 조회
    IMAGE_DIGESTS=$(aws ecr list-images --repository-name $repo --query 'imageIds[*].imageDigest' --output text ${PROFILE_STRING})
    
    # 이미지가 존재하면 삭제
    if [ -n "$IMAGE_DIGESTS" ]; then
        echo "리포지토리 $repo의 이미지 삭제 중..."
        for digest in $IMAGE_DIGESTS; do
            echo "aws ecr batch-delete-image --repository-name $repo --image-ids imageDigest=$digest ${PROFILE_STRING}"
            aws ecr batch-delete-image --repository-name $repo --image-ids imageDigest=$digest ${PROFILE_STRING}
        done
    fi
    
    # 리포지토리 삭제
    echo "리포지토리 $repo 삭제..."
    echo "aws ecr delete-repository --repository-name $repo --force ${PROFILE_STRING}"
    aws ecr delete-repository --repository-name $repo --force ${PROFILE_STRING}
}

delete_ecr_repository public.ecr.aws/eks/aws-load-balancer-controller
delete_ecr_repository registry.k8s.io/autoscaling/cluster-autoscaler
delete_ecr_repository public.ecr.aws/nginx/nginx
delete_ecr_repository public-ecr-9641173/eks/aws-load-balancer-controller

echo "ECR 리소스 정리 완료"
