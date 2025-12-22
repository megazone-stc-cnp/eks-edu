#!/bin/bash

if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

ARGOCD_CAPABILITY_ROLE_NAME=eks-edu-argocd-capability-role-${IDE_NAME}
CAPABILITY_NAME=argocd-${IDE_NAME}
USER_NAME=hcseo
ROLE_TYPE=ADMIN     #EDITOR / VIEWER
# ==============================================================
echo "aws sso-admin list-instances --region ${AWS_REGION} \\
    --query 'Instances[0].InstanceArn || ``' \\
    --output text ${PROFILE_STRING}"
echo ""

# Get your Identity Center instance ARN (replace region if your IDC instance is in a different region)
export IDC_INSTANCE_ARN=$(
  aws sso-admin list-instances \
  --region ${AWS_REGION} \
  --query 'Instances[0].InstanceArn || ``' \
  --output text ${PROFILE_STRING})

echo "aws sso-admin list-instances --region ${AWS_REGION} --query 'Instances[0].IdentityStoreId || ``' --output text ${PROFILE_STRING}"
echo ""

echo "aws identitystore list-users \\
  --region ${AWS_REGION} \\
  --identity-store-id $(aws sso-admin list-instances --region ${AWS_REGION} --query 'Instances[0].IdentityStoreId || ``' --output text ${PROFILE_STRING}) \\
  --query \"Users[?UserName==\`${USER_NAME}\`].UserId\" --output text ${PROFILE_STRING}"
echo ""

# Get a user ID for RBAC mapping (replace with your username and region if needed)
export IDC_USER_ID=$(aws identitystore list-users \
  --region ${AWS_REGION} \
  --identity-store-id $(aws sso-admin list-instances --region ${AWS_REGION} --query 'Instances[0].IdentityStoreId || ``' --output text ${PROFILE_STRING}) \
  --query "Users[?UserName==\`${USER_NAME}\`].UserId" --output text ${PROFILE_STRING})

echo "IDC_INSTANCE_ARN=$IDC_INSTANCE_ARN"
echo "IDC_USER_ID=$IDC_USER_ID"

echo "aws eks update-capability \
  --region ${AWS_REGION} \
  --cluster-name ${CLUSTER_NAME} \
  --capability-name ${CAPABILITY_NAME} \
  --role-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:role/${ARGOCD_CAPABILITY_ROLE_NAME}" \
  --configuration '{
  \"argoCd\": {
    \"rbacRoleMappings\": {
      \"addOrUpdateRoleMappings\": [
        {
          \"role\": \"${ROLE_TYPE}\",
          \"identities\": [
            { \"id\": \"$IDC_USER_ID\", \"type\": \"SSO_USER\" }
          ]
        }
      ]
    }
  }
}' ${PROFILE_ARGS[@]}"
echo ""

aws eks update-capability \
  --region ${AWS_REGION} \
  --cluster-name ${CLUSTER_NAME} \
  --capability-name ${CAPABILITY_NAME} \
  --role-arn arn:aws:iam::${AWS_ACCOUNT_ID}:role/${ARGOCD_CAPABILITY_ROLE_NAME} \
  --configuration "{
   \"argoCd\": {
     \"rbacRoleMappings\": {
       \"addOrUpdateRoleMappings\": [
         {
           \"role\": \"${ROLE_TYPE}\",
           \"identities\": [
             { "id": "$IDC_USER_ID", "type": "SSO_USER" }
           ]
         }
       ]
     }
   }
 }"