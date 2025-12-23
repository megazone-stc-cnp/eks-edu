
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

cat >tmp/ecr_helm_app.json <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ${APP_NAME}
  namespace: ${NAMESPACE_NAME}
spec:
  source:
    repoURL: ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPOSITORY_NAME}
    targetRevision: chart-version
    chart: ${REVISION_NAME}
    helm:
      valueFiles:
        - values.yaml
EOF

kubectl apply -f tmp/ecr_helm_app.json