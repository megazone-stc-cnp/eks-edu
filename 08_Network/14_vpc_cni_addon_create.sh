#!/bin/bash
if [ -z "$1" ]; then
    echo "사용법: $0 <ADDON_VERSION>"
    exit 1
fi
ADDON_VERSION=$1

if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh
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
# export VPC_ID=vpc-045741095e8efe028
# export AWS_AZ1=ap-northeast-1a
# export AWS_AZ2=ap-northeast-1c
# export AWS_PRIVATE_SUBNET1=subnet-01b7dce75dc1b79e5
# export AWS_PRIVATE_SUBNET2=subnet-0cf18e5c66c385020
# export EKS_ADDITIONAL_SG=sg-03290c4da8c08c351
# export NEW_POD_SUBNET1=subnet-07e90b5d0fd7cf445
# export NEW_POD_SUBNET2=subnet-03201c33f1b4828bd
# export EKS_CLUSTER_SG=sg-0452354091f449b82

ADDON_NAME=vpc-cni
VPC_CNI_ROLE_NAME=eks-edu-vpc-cni-pod-identity-role-${IDE_NAME}
# ==================================================================
# echo aws eks create-addon --cluster-name ${EKS_CLUSTER_NAME} --addon-name ${ADDON_NAME} --addon-version ${VPC_CNI_VERSION} --configuration-values "{\"env\":{\"AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG\":\"true\",     \"ENABLE_PREFIX_DELEGATION\": \"true\"}, \"EniConfig\": {\"create\": true,\"region\": \"${REGION_NAME}\",\"subnets\": { \"${AZ_1_NAME}\": { \"id\": \"${POD_SUBNET_ID_1}\", \"securityGroups\": [ \"${EKS_ADD_SG}\" ] },\"${AZ_2_NAME}\": { \"id\": \"${POD_SUBNET_ID_2}\", \"securityGroups\": [ \"${EKS_ADD_SG}\" ] } } } }" --service-account-role-arn arn:aws:iam::${ACCOUNT_ID}:role/${VPC_CNI_ROLE_NAME} --resolve-conflicts OVERWRITE --profile ${PROFILE_NAME} --region ${REGION_NAME}
cat >configuration-values.json<<EOF
{
  "env": {
    "AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG": "true",
    "ENI_CONFIG_LABEL_DEF": "topology.kubernetes.io/zone",
    "ENABLE_PREFIX_DELEGATION": "true",
    "WARM_PREFIX_TARGET": "1",
    "WARM_ENI_TARGET": "1",
    "WARM_IP_TARGET": "2"
  },
  "eniConfig": {
    "create": true,
    "region": "${AWS_REGION}",
    "subnets": {
      "${AWS_AZ1}": {
        "id": "${NEW_POD_SUBNET1}",
        "securityGroups": ["${EKS_CLUSTER_SG}"]
      },
      "${AWS_AZ2}": {
        "id": "${NEW_POD_SUBNET2}",
        "securityGroups": ["${EKS_CLUSTER_SG}"]
      }
    }
  }
}
EOF

echo "aws eks create-addon \\
    --cluster-name ${CLUSTER_NAME} \\
    --addon-name ${ADDON_NAME} \\
    --addon-version ${ADDON_VERSION} \\
    --configuration-values 'file://configuration-values.json' \\
    --resolve-conflicts OVERWRITE \\
    --pod-identity-associations \"serviceAccount=aws-node,roleArn=arn:aws:iam::${AWS_REPO_ACCOUNT}:role/${VPC_CNI_ROLE_NAME}\" ${PROFILE_STRING}"

aws eks create-addon \
    --cluster-name ${CLUSTER_NAME} \
    --addon-name ${ADDON_NAME} \
    --addon-version ${ADDON_VERSION} \
    --configuration-values 'file://configuration-values.json' \
    --resolve-conflicts OVERWRITE \
    --pod-identity-associations "serviceAccount=aws-node,roleArn=arn:aws:iam::${AWS_REPO_ACCOUNT}:role/${VPC_CNI_ROLE_NAME}" ${PROFILE_STRING}

# --service-account-role-arn arn:aws:iam::${ACCOUNT_ID}:role/${VPC_CNI_ROLE_NAME} \