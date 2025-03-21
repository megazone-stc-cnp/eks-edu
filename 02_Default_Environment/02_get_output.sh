#!/bin/bash
if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh

STACK_NAME=eks-workshop-vpc-${EMPLOY_ID}
# ==================================================================
PROFILE_STRING=""
if [ -n "$PROFILE_NAME" ]; then
    PROFILE_STRING="--profile ${PROFILE_NAME}"
fi

echo "aws cloudformation describe-stacks \\
    --stack-name ${STACK_NAME} --query "Stacks[0].Outputs" \\
    --region ${AWS_REGION} ${PROFILE_STRING} --output json"

aws cloudformation describe-stacks \
    --stack-name ${STACK_NAME} --query "Stacks[0].Outputs" \
    --region ${AWS_REGION} ${PROFILE_STRING} --output json | tee result.json

# sh ../01_Container/02_get_output.sh | jq -r '.[] | select(.OutputKey=="VpcId") | .OutputValue'
echo "env.sh 에 넣어주세요."
echo "export VPC_ID=$(cat result.json | jq -r '.[] | select(.OutputKey=="VpcId") | .OutputValue')"
echo "export AWS_AZ1=$(cat result.json | jq -r '.[] | select(.OutputKey=="PrivateSubnet01AZ") | .OutputValue')"
echo "export AWS_AZ2=$(cat result.json | jq -r '.[] | select(.OutputKey=="PrivateSubnet02AZ") | .OutputValue')"
echo "export AWS_PRIVATE_SUBNET1=$(cat result.json | jq -r '.[] | select(.OutputKey=="PrivateSubnet01") | .OutputValue')"
echo "export AWS_PRIVATE_SUBNET2=$(cat result.json | jq -r '.[] | select(.OutputKey=="PrivateSubnet02") | .OutputValue')"
echo "export EKS_ADDITIONAL_SG=$(cat result.json | jq -r '.[] | select(.OutputKey=="SecurityGroups") | .OutputValue')"
