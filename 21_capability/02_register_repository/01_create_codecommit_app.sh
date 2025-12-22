
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
# ==============================================================
# Check if tmp directory exists, if not create it
if [ ! -d "tmp" ]; then
    mkdir -p tmp
fi

cat >tmp/codecommit_app.json <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ${APP_NAME}
  namespace: ${NAMESPACE_NAME}
spec:
  source:
    repoURL: https://git-codecommit.${AWS_REGION}.amazonaws.com/v1/repos/${REPOSITORY_NAME}
    targetRevision: ${REVISION_NAME}
    path: ${PATH_NAME}
EOF

kubectl apply -f tmp/codecommit_app.json