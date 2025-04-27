#!/bin/bash
if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh

STACK_NAME=eks-workshop-${IDE_NAME}-eks-vpc
# ==================================================================


echo "aws cloudformation describe-stacks \\
    --stack-name ${STACK_NAME} --query "Stacks[0].Outputs" ${PROFILE_STRING} --output json"

aws cloudformation describe-stacks \
    --stack-name ${STACK_NAME} --query "Stacks[0].Outputs" ${PROFILE_STRING} --output json | tee result.json

# sh ../01_Container/02_get_output.sh | jq -r '.[] | select(.OutputKey=="VpcId") | .OutputValue'
if [ -f "./local_env.sh" ];then
    rm -rf local_env.sh
fi
echo "#!/bin/bash" >> local_env.sh
echo "export VPC_ID=$(cat result.json | jq -r '.[] | select(.OutputKey=="VpcId") | .OutputValue')" >> local_env.sh
echo "export AWS_AZ1=$(cat result.json | jq -r '.[] | select(.OutputKey=="PrivateSubnet01AZ") | .OutputValue')" >> local_env.sh
echo "export AWS_AZ2=$(cat result.json | jq -r '.[] | select(.OutputKey=="PrivateSubnet02AZ") | .OutputValue')" >> local_env.sh
echo "export AWS_PRIVATE_SUBNET1=$(cat result.json | jq -r '.[] | select(.OutputKey=="PrivateSubnet01") | .OutputValue')" >> local_env.sh
echo "export AWS_PRIVATE_SUBNET2=$(cat result.json | jq -r '.[] | select(.OutputKey=="PrivateSubnet02") | .OutputValue')" >> local_env.sh
echo "export EKS_ADDITIONAL_SG=$(cat result.json | jq -r '.[] | select(.OutputKey=="SecurityGroups") | .OutputValue')" >> local_env.sh
echo "export AWS_PUBLIC_SUBNET1=$(cat result.json | jq -r '.[] | select(.OutputKey=="PublicSubnet01") | .OutputValue')" >> local_env.sh
echo "export AWS_PUBLIC_SUBNET2=$(cat result.json | jq -r '.[] | select(.OutputKey=="PublicSubnet02") | .OutputValue')" >> local_env.sh
