#!/bin/bash

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <ADDON_VERSION> <ROLE_NAME>"
  exit 1
fi

ADDON_VERSION=$1
ROLE_NAME=$2

echo "ADDON_VERSION: ${ADDON_VERSION}"
echo "ROLE_NAME: ${ROLE_NAME}"

if [ ! -f "../../env.sh" ];then
  echo "env.sh 파일 세팅을 해주세요."
  exit 1
fi
. ../../env.sh

ADDON_NAME=vpc-cni
# ==================================================================
PROFILE_STRING=""
if [ -n "$PROFILE_NAME" ]; then
    PROFILE_STRING="--profile ${PROFILE_NAME}"
fi

rm -rf configuration-values.json

if [ -z "${SECURITY_GROUPS}" ]; then
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
        "id": "${AWS_POD_SUBNET1}",
        "securityGroups": []
      },
      "${AWS_AZ2}": {
        "id": "${AWS_POD_SUBNET2}",
        "securityGroups": []
      }
    }
  }
}
EOF
else
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
        "id": "${AWS_POD_SUBNET1}",
        "securityGroups": [${SECURITY_GROUPS}]
      },
      "${AWS_AZ2}": {
        "id": "${AWS_POD_SUBNET2}",
        "securityGroups": [${SECURITY_GROUPS}]
      }
    }
  }
}
EOF
fi
# ${SECURITY_GROUPS}
aws eks update-addon \
    --cluster-name ${EKS_CLUSTER_NAME} \
    --addon-name ${ADDON_NAME} \
    --addon-version ${ADDON_VERSION} \
    --service-account-role-arn arn:aws:iam::${ACCOUNT_ID}:role/${ROLE_NAME} \
    --resolve-conflicts PRESERVE \
    --configuration-values 'file://configuration-values.json'

echo "INFO: ${ADDON_NAME} Addon Complete check in aws management console !!!"