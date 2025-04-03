#!/bin/bash

if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh

if [ ! -f "./local_env.sh" ];then
	echo "local_env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ./local_env.sh
# export OIDC_ID=

SERVICE_ACCOUNT_NAME=eks-edu-service-account-${IDE_NAME}
POLICY_NAME=eks-edu-workload-policy-${IDE_NAME}
ROLE_NAME=eks-edu-workload-role-${IDE_NAME}
NAMESPACE_NAME=default
# ==================================================================

cat >my-deployment.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      serviceAccountName: ${SERVICE_ACCOUNT_NAME}
      containers:
      - name: my-app
        image: public.ecr.aws/nginx/nginx:1.27
EOF

kubectl apply -f my-deployment.yaml
