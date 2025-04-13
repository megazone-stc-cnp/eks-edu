#!/bin/bash

if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

STACK_NAME=eks-workshop-vpc-${IDE_NAME}
# ==================================================================
# Check if the stack already exists
echo "${STACK_NAME} 스택 존재 여부 확인 중....."
echo "aws cloudformation describe-stacks \\
      --stack-name ${STACK_NAME} ${PROFILE_STRING}"

if aws cloudformation describe-stacks --stack-name ${STACK_NAME} ${PROFILE_STRING} &> /dev/null; then
    echo "${STACK_NAME} 스택이 이미 존재합니다."
    exit 1
fi
echo "${STACK_NAME} 스택 존재 하지 않습니다."
echo ""

# Create VPC for EKS
echo "aws cloudformation create-stack \\
  --stack-name ${STACK_NAME} \\
  --template-body file://amazon-eks-vpc-private-subnets.yaml \\
  --capabilities CAPABILITY_NAMED_IAM ${PROFILE_STRING}"

echo "기본 VPC 생성중....."
aws cloudformation create-stack \
  --stack-name ${STACK_NAME} \
  --template-body file://amazon-eks-vpc-private-subnets.yaml \
  --capabilities CAPABILITY_NAMED_IAM ${PROFILE_STRING}

aws cloudformation wait stack-create-complete \
  --stack-name ${STACK_NAME} ${PROFILE_STRING}
echo "기본 VPC 생성완료....."

# Create Env.sh for VPC (vpc_env.sh)
VPC_ENV_FILE_PATH=../../vpc_env.sh
aws cloudformation describe-stacks \
    --stack-name ${STACK_NAME} --query "Stacks[0].Outputs" ${PROFILE_STRING} --output json | tee result.json

if [ -f "${VPC_ENV_FILE_PATH}" ];then
    rm -rf ${VPC_ENV_FILE_PATH}
fi
cat > ${VPC_ENV_FILE_PATH} << EOF
#!/bin/bash
export VPC_ID=$(cat result.json | jq -r '.[] | select(.OutputKey=="VpcId") | .OutputValue')
export AWS_AZ1=$(cat result.json | jq -r '.[] | select(.OutputKey=="PrivateSubnet01AZ") | .OutputValue')
export AWS_AZ2=$(cat result.json | jq -r '.[] | select(.OutputKey=="PrivateSubnet02AZ") | .OutputValue')
export AWS_PRIVATE_SUBNET1=$(cat result.json | jq -r '.[] | select(.OutputKey=="PrivateSubnet01") | .OutputValue')
export AWS_PRIVATE_SUBNET2=$(cat result.json | jq -r '.[] | select(.OutputKey=="PrivateSubnet02") | .OutputValue')
export EKS_ADDITIONAL_SG=$(cat result.json | jq -r '.[] | select(.OutputKey=="SecurityGroups") | .OutputValue')
export AWS_PUBLIC_SUBNET1=$(cat result.json | jq -r '.[] | select(.OutputKey=="PublicSubnet01") | .OutputValue')
export AWS_PUBLIC_SUBNET2=$(cat result.json | jq -r '.[] | select(.OutputKey=="PublicSubnet02") | .OutputValue')
export VPC_CIDR=$(cat result.json | jq -r '.[] | select(.OutputKey=="VpcCidr") | .OutputValue')
EOF