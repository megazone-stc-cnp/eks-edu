#!/bin/bash
if [ ! -f "../env.sh" ];then
	echo "Root 디렉토리에 env.sh 파일 세팅을 해주세요."
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
# ======================================================

eksctl delete cluster --name ${CLUSTER_NAME} \
	--region ${AWS_REGION} ${PROFILE_STRING}

echo "EKS 삭제중....."
aws cloudformation wait stack-delete-complete \
    --stack-name eks-edu-cluster-${EMPLOY_ID} \
	--region ${AWS_REGION} ${PROFILE_STRING}
echo "EKS 삭제 완료....."    

