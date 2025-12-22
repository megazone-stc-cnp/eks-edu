
#!/bin/bash

if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

REPOSITORY_NAME=repository-name
GITHUB_USER_NAME=your-username
OWNER_NAME=owner
# ==============================================================
echo "aws secretsmanager create-secret \\
        --name argocd/${REPOSITORY_NAME} \\
        --description \"GitHub credentials for Argo CD\" \\
        --secret-string '{\"username\":\"${GITHUB_USER_NAME}\","token":"your-personal-access-token"}' ${PROFILE_STRING}"


aws secretsmanager create-secret \
  --name argocd/my-repo \
  --description "GitHub credentials for Argo CD" \
  --secret-string ""{\"username\":\"${GITHUB_USER_NAME}\",\"token\":\"your-personal-access-token\"}"  ${PROFILE_STRING}