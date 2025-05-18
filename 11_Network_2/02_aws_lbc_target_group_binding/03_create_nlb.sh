#!/bin/bash
if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

if [ ! -f "../../vpc_env.sh" ];then
	echo "vpc_env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../vpc_env.sh

if [ ! -f "./local_env.sh" ];then
	echo "local_env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ./local_env.sh

# NLB 이름 설정
NLB_NAME="eks-edu-nlb-${IDE_NAME}"
TARGET_GROUP_NAME="eks-edu-nlb-tg-${IDE_NAME}"
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