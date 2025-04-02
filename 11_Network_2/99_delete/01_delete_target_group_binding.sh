#!/bin/bash
if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh
# export VPC_ID=vpc-0264324861f559add
# export AWS_AZ1=ap-northeast-1a
# export AWS_AZ2=ap-northeast-1c
# export AWS_PRIVATE_SUBNET1=subnet-06a6dc4043dc1e5b6
# export AWS_PRIVATE_SUBNET2=subnet-0dadf6ad0b509415f
# export EKS_ADDITIONAL_SG=sg-0a5e29c6c67f89643
# export AWS_PUBLIC_SUBNET1=subnet-059cb0b98cd7850b9
# export AWS_PUBLIC_SUBNET2=subnet-0b12d717922b90cc2
# export TARGET_GROUP_ARN=

TARGET_GROUP_BINDING_NAME=eks-edu-target-group-binding-${IDE_NAME}
# =========================================================================================
kubectl delete -f ../04_target_group_binding/tmp/${TARGET_GROUP_BINDING_NAME}.yaml