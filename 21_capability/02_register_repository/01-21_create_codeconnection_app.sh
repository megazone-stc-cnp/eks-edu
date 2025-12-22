
#!/bin/bash

if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

APP_NAME=my-app
NAMESPACE_NAME=argocd
REPOSITORY_NAME=repository-name
REVISION_NAME=main
PATH_NAME=kubernetes/manifests
CONNECTION_ID=connection-id
OWNER_NAME=owner
# ==============================================================
# Check if tmp directory exists, if not create it
if [ ! -d "tmp" ]; then
    mkdir -p tmp
fi

cat >tmp/code_connection_app.json <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ${APP_NAME}
  namespace: ${NAMESPACE_NAME}
spec:
  source:
    repoURL: https://codeconnections.${AWS_REGION}.amazonaws.com/git-http/${AWS_ACCOUNT_ID}/${AWS_REGION}/${CONNECTION_ID}/${OWNER_NAME}/${REPOSITORY_NAME}.git
    targetRevision: ${REVISION_NAME}
    path: kubernetes/manifests
EOF

kubectl apply -f tmp/code_connection_app.json