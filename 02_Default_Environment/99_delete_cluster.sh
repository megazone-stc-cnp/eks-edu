#!/bin/bash
if [ ! -f "../env.sh" ];then
	echo "Root 디렉토리에 env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh
CLUSTER_NAME=eks-edu-cluster-${EMPLOY_ID}
# ======================================================
PROFILE_STRING=""
if [ -n "$PROFILE_NAME" ]; then
    PROFILE_STRING="--profile ${PROFILE_NAME}"
fi

eksctl delete cluster --name ${CLUSTER_NAME} \
	--region ${AWS_REGION} ${PROFILE_STRING}

echo "EKS 삭제중....."
aws cloudformation wait stack-delete-complete \
    --stack-name eks-edu-cluster-${EMPLOY_ID} \
	--region ${AWS_REGION} ${PROFILE_STRING}
echo "EKS 삭제 완료....."    

eksctl delete cluster --name eks-workshop-vpc-${EMPLOY_ID} \
	--region ${AWS_REGION} ${PROFILE_STRING}

echo "VPC 삭제중....."
aws cloudformation wait stack-delete-complete \
    --stack-name eks-workshop-vpc-${EMPLOY_ID} \
	--region ${AWS_REGION} ${PROFILE_STRING}
echo "VPC 삭제 완료....."