#!/bin/bash

if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

if [ ! -f "./local_env.sh" ];then
	echo "local_env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ./local_env.sh

POLICY_NAME="${APP_NAME}-policy-${IDE_NAME}"
ROLE_NAME="${APP_NAME}-role-${IDE_NAME}"
# ==================================================================
if [ ! -d "tmp" ]; then
    mkdir -p tmp
fi

# Check if policy exists
EXISTING_POLICY=$(aws iam get-policy --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${POLICY_NAME} ${PROFILE_STRING} 2>/dev/null)

if [ ! -z "$EXISTING_POLICY" ]; then
    echo "Policy ${POLICY_NAME} 가 존재합니다."
    exit 0
fi

echo "$POLICY_JSON" > tmp/${POLICY_NAME}.json

echo "${POLICY_NAME} 생성중..."
# eks user policy 생성
echo "aws iam create-policy --policy-name ${POLICY_NAME} \\
	--policy-document file://tmp/${POLICY_NAME}.json ${PROFILE_STRING}"

aws iam create-policy --policy-name ${POLICY_NAME} \
	--policy-document file://tmp/${POLICY_NAME}.json ${PROFILE_STRING}

aws iam wait policy-exists \
    --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${POLICY_NAME} ${PROFILE_STRING}

echo "${POLICY_NAME} 생성완료..."
echo ""

echo "eksctl create iamserviceaccount \\
        --name ${SERVICE_ACCOUNT_NAME} \\
        --namespace ${NAMESPACE_NAME} \\
        --cluster ${CLUSTER_NAME} \\
        --attach-policy-arn \"arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${POLICY_NAME}\" \\
        --approve \\
        --role-name ${ROLE_NAME} \\
        --region ${AWS_REGION} \\
        --role-only"
echo ""

eksctl create iamserviceaccount \
  --name ${SERVICE_ACCOUNT_NAME} \
  --namespace ${NAMESPACE_NAME} \
  --cluster ${CLUSTER_NAME} \
  --attach-policy-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${POLICY_NAME}" \
  --approve \
  --role-name ${ROLE_NAME} \
  --region ${AWS_REGION} \
  --role-only