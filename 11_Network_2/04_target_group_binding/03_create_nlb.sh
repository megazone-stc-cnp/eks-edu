#!/bin/bash
if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
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

if [ ! -f "./local_env.sh" ];then
	echo "local_env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ./local_env.sh
# export VPC_ID=vpc-0264324861f559add
# export AWS_AZ1=ap-northeast-1a
# export AWS_AZ2=ap-northeast-1c
# export AWS_PRIVATE_SUBNET1=subnet-06a6dc4043dc1e5b6
# export AWS_PRIVATE_SUBNET2=subnet-0dadf6ad0b509415f
# export EKS_ADDITIONAL_SG=sg-0a5e29c6c67f89643
# export AWS_PUBLIC_SUBNET1=subnet-059cb0b98cd7850b9
# export AWS_PUBLIC_SUBNET2=subnet-0b12d717922b90cc2
# export NLB_SECURITY_GROUP_ID=sg-0506823f14c3411f1

# NLB 이름 설정
NLB_NAME="eks-edu-nlb-${IDE_NAME}"
TARGET_GROUP_NAME="eks-edu-tg-${IDE_NAME}"
# ==============================================================
# NLB 생성
echo "Creating Network Load Balancer: ${NLB_NAME}"
NLB_ARN=$(aws elbv2 create-load-balancer \
    --name ${NLB_NAME} \
    --type network \
    --security-groups ${NLB_SECURITY_GROUP_ID} \
    --subnets "${AWS_PUBLIC_SUBNET1}" "${AWS_PUBLIC_SUBNET2}" ${PROFILE_STRING} \
    --query 'LoadBalancers[0].LoadBalancerArn' \
    --output text)

if [ -z "$NLB_ARN" ]; then
    echo "NLB 생성에 실패했습니다."
    exit 1
fi

echo "NLB가 성공적으로 생성되었습니다. ARN: ${NLB_ARN}"

# 타겟 그룹 생성

echo "Creating Target Group: ${TARGET_GROUP_NAME}"
TG_ARN=$(aws elbv2 create-target-group \
    --name ${TARGET_GROUP_NAME} \
    --protocol TCP \
    --port 80 \
    --vpc-id ${VPC_ID} \
    --target-type ip ${PROFILE_STRING} \
    --query 'TargetGroups[0].TargetGroupArn' \
    --output text)

if [ -z "$TG_ARN" ]; then
    echo "타겟 그룹 생성에 실패했습니다."
    exit 1
fi

echo "타겟 그룹이 성공적으로 생성되었습니다. ARN: ${TG_ARN}"

# 리스너 생성
echo "Creating Listener"
LISTENER_ARN=$(aws elbv2 create-listener \
    --load-balancer-arn ${NLB_ARN} \
    --protocol TCP \
    --port 80 \
    --default-actions Type=forward,TargetGroupArn=${TG_ARN} ${PROFILE_STRING} \
    --query 'Listeners[0].ListenerArn' \
    --output text)

if [ -z "$LISTENER_ARN" ]; then
    echo "리스너 생성에 실패했습니다."
    exit 1
fi

echo "리스너가 성공적으로 생성되었습니다. ARN: ${LISTENER_ARN}"

echo "NLB 설정이 완료되었습니다."
echo "NLB ARN: ${NLB_ARN}"
echo "Target Group ARN: ${TG_ARN}"
echo "Listener ARN: ${LISTENER_ARN}"

echo "export TARGET_GROUP_ARN=${TG_ARN}" >> local_env.sh
echo "export LISTENER_ARN=${TG_ARN}" >> local_env.sh
echo "export NLB_ARN=${NLB_ARN}" >> local_env.sh
echo "" >> local_env.sh