#!/bin/bash
if [ ! -f "../../env.sh" ];then
	echo "Root 디렉토리에 env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

CAPABILITY_NAME=argocd-${IDE_NAME}
ARGOCD_CAPABILITY_ROLE_NAME=eks-edu-argocd-capability-role-${IDE_NAME}
# export AWS_REGION=ap-northeast-2
# ======================================================

# capability 삭제
CAPABILITY_EXISTED=$(aws eks describe-capability --cluster-name $CLUSTER_NAME --capability-name ${CAPABILITY_NAME} --query 'capability.capabilityName' ${PROFILE_STRING} --no-cli-pager --output text 2> /dev/null)
if [ "$CAPABILITY_EXISTED" == $CAPABILITY_NAME ]; then
  echo "aws eks delete-capability \\
    --region ${AWS_REGION} \\
    --cluster-name ${CLUSTER_NAME} \\
    --capability-name ${CAPABILITY_NAME} ${PROFILE_STRING}"

  aws eks delete-capability \
    --region ${AWS_REGION} \
    --cluster-name ${CLUSTER_NAME} \
    --capability-name ${CAPABILITY_NAME} ${PROFILE_STRING}
fi

# Role 삭제
CAPABILITY_ROLE_EXISTS=$(aws iam get-role --role-name ${ARGOCD_CAPABILITY_ROLE_NAME} ${PROFILE_STRING} 2>&1 || echo "ROLE_NOT_FOUND")
if [[ ! "$CAPABILITY_ROLE_EXISTS" == *"ROLE_NOT_FOUND"* ]]; then
    CAPABILITY_POLICIES=$(aws iam list-attached-role-policies --role-name "$CAPABILITY_NAME" --query 'AttachedPolicies[].PolicyArn' --output text ${PROFILE_STRING})

    for POLICY_ARN in $CAPABILITY_POLICIES; do
        echo "aws iam detach-role-policy --role-name $ARGOCD_CAPABILITY_ROLE_NAME --policy-arn $POLICY_ARN ${PROFILE_STRING}"
        aws iam detach-role-policy --role-name "$ARGOCD_CAPABILITY_ROLE_NAME" --policy-arn "$POLICY_ARN" ${PROFILE_STRING}
    done

    IRSA_INLINE_POLICIES=$(aws iam list-role-policies --role-name "$ARGOCD_CAPABILITY_ROLE_NAME" --query 'PolicyNames[]' --output text ${PROFILE_STRING})

    for POLICY_NAME in $IRSA_INLINE_POLICIES; do
      echo "aws iam delete-role-policy --role-name $ARGOCD_CAPABILITY_ROLE_NAME --policy-name $POLICY_NAME ${PROFILE_STRING}"
      aws iam delete-role-policy --role-name "$ARGOCD_CAPABILITY_ROLE_NAME" --policy-name "$POLICY_NAME" ${PROFILE_STRING}
    done

	echo "aws iam delete-role --role-name $ARGOCD_CAPABILITY_ROLE_NAME ${PROFILE_STRING}"
	aws iam delete-role --role-name $ARGOCD_CAPABILITY_ROLE_NAME ${PROFILE_STRING}
fi
