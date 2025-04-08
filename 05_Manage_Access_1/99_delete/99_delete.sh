#!/bin/bash

if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

IAM_USER=eks-edu-user-${IDE_NAME}
# ==================================================================

echo "# ${IAM_USER} IAM 사용자 액세스 키 삭제"
for key in $(aws iam list-access-keys --user-name ${IAM_USER} --query 'AccessKeyMetadata[*].AccessKeyId' --output text ${PROFILE_STRING}); do
    echo "aws iam delete-access-key --user-name ${IAM_USER} --access-key-id $key ${PROFILE_STRING}"
    aws iam delete-access-key --user-name ${IAM_USER} --access-key-id $key ${PROFILE_STRING}
done

echo "# login Profile 삭제"
echo "aws iam delete-login-profile --user-name ${IAM_USER} ${PROFILE_STRING}"
aws iam delete-login-profile --user-name ${IAM_USER} ${PROFILE_STRING} 2>/dev/null || true

echo "# ${IAM_USER} 연결된 정책 분리"
for policy in $(aws iam list-attached-user-policies --user-name ${IAM_USER} --query 'AttachedPolicies[*].PolicyArn' --output text ${PROFILE_STRING}); do
    echo "aws iam detach-user-policy --user-name ${IAM_USER} --policy-arn $policy ${PROFILE_STRING}"
    aws iam detach-user-policy --user-name ${IAM_USER} --policy-arn $policy ${PROFILE_STRING}
done

# Delete inline policies
echo "# ${IAM_USER} Inline Policy 삭제"
for policy in $(aws iam list-user-policies --user-name ${IAM_USER} --query 'PolicyNames[*]' --output text ${PROFILE_STRING}); do
    echo "aws iam delete-user-policy --user-name ${IAM_USER} --policy-name $policy ${PROFILE_STRING}"
    aws iam delete-user-policy --user-name ${IAM_USER} --policy-name $policy ${PROFILE_STRING}
done

# Finally delete the IAM user
echo "# ${IAM_USER} USER 삭제"
echo "aws iam delete-user --user-name ${IAM_USER} ${PROFILE_STRING}"

aws iam delete-user --user-name ${IAM_USER} ${PROFILE_STRING}