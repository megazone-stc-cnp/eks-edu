#!/bin/bash

if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

REPOSITORY_NAME=app_yaml
GITHUB_USER_NAME=megazone-hcseo
NAMESPACE_NAME=argocd
OWNER_NAME=mzc-ssu-smu-amu
# 아래 값은 커밋하지 말것
SECRET_MANAGER_NAME=app_yaml_2
# ==============================================================
echo "aws secretsmanager create-secret \\
        --name ${NAMESPACE_NAME}/${SECRET_MANAGER_NAME} \\
        --region ${AWS_REGION} \\
        --description \"GitHub credentials for Argo CD\" \\
        --secret-string '{\"username\":\"${GITHUB_USER_NAME}\","token":"${GITHUB_TOKEN}"}' $--query \"ARN\" {PROFILE_STRING}"


RESULT=$(aws secretsmanager create-secret \
  --name ${NAMESPACE_NAME}/${SECRET_MANAGER_NAME} \
  --region ${AWS_REGION} \
  --description "GitHub credentials for Argo CD" \
  --secret-string "{\"username\":\"${GITHUB_USER_NAME}\",\"token\":\"${GITHUB_TOKEN}\"}" ${PROFILE_STRING} --query "ARN" --output json)

cat > local_env.sh << EOF
#!/bin/bash
export SECRET_MANAGER_ARN=${RESULT}
EOF

