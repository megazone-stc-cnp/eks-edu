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
# export EKS_VERSION=1.31

if [ ! -f "./local_env.sh" ];then
	echo "local_env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ./local_env.sh
# export VPC_ID=vpc-045741095e8efe028
# export AWS_AZ1=ap-northeast-1a
# export AWS_AZ2=ap-northeast-1c
# export AWS_PRIVATE_SUBNET1=subnet-01b7dce75dc1b79e5
# export AWS_PRIVATE_SUBNET2=subnet-0cf18e5c66c385020
# export EKS_ADDITIONAL_SG=sg-03290c4da8c08c351

# ==================================================================
new_subnet_id_1=$(
    aws ec2 create-subnet \
        --vpc-id ${VPC_ID} \
        --availability-zone ${AWS_AZ1} \
        --cidr-block 192.168.2.0/24 \
        --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=eks-custom-networking-vpc-PrivateSubnet01},{Key=kubernetes.io/role/internal-elb,Value=1}]' \
        --query Subnet.SubnetId \
        --region ${AWS_REGION} ${PROFILE_STRING} \
        --output text
)

new_subnet_id_2=$(
    aws ec2 create-subnet \
        --vpc-id ${VPC_ID} \
        --availability-zone ${AWS_AZ2} \
        --cidr-block 192.168.3.0/24 \
        --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=eks-custom-networking-vpc-PrivateSubnet02},{Key=kubernetes.io/role/internal-elb,Value=1}]' \
        --query Subnet.SubnetId \
        --region ${AWS_REGION} ${PROFILE_STRING} \
        --output text
)

echo "POD_SUBNET ${AWS_AZ1} : ${new_subnet_id_1}"
echo "POD_SUBNET ${AWS_AZ2} : ${new_subnet_id_2}"

echo "export NEW_POD_SUBNET1=${new_subnet_id_1}" >> local_env.sh
echo "export NEW_POD_SUBNET2=${new_subnet_id_2}" >> local_env.sh

