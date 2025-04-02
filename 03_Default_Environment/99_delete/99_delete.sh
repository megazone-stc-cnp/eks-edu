#!/bin/bash
if [ ! -f "../../env.sh" ];then
	echo "Root 디렉토리에 env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh
# export AWS_REGION=ap-northeast-1
# export IDE_NAME=9641173
# export PROFILE_NAME=cnp-key
# export AWS_REPO_ACCOUNT=539666729110
# export HOME_DIR=/Users/mzc01-hcseo/00_PARA/01_project/autoever-eks-edu/source/eks-edu
# export EKS_VERSION=1.31
# export CLUSTER_NAME=eks-edu-cluster-${IDE_NAME}
# ======================================================
echo "eksctl delete cluster --name ${CLUSTER_NAME} ${PROFILE_STRING}"
echo "EKS 삭제중....."
eksctl delete cluster --name ${CLUSTER_NAME} ${PROFILE_STRING}

aws cloudformation wait stack-delete-complete \
    --stack-name eks-edu-cluster-${IDE_NAME}-cluster ${PROFILE_STRING}
echo "EKS 삭제 완료....."

aws cloudformation delete-stack \
  --stack-name eks-workshop-vpc-${IDE_NAME} ${PROFILE_STRING}

echo "VPC 삭제중....."
aws cloudformation wait stack-delete-complete \
    --stack-name eks-workshop-vpc-${IDE_NAME} ${PROFILE_STRING}
if [ -f "../../vpc_env.sh" ];then
	rm -rf ../../vpc_env.sh
fi
echo "VPC 삭제 완료....."