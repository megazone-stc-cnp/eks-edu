#!/bin/bash

if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh

SERVICE_ACCOUNT_NAME=eks-edu-pod-identity-service-account-${IDE_NAME}
POLICY_NAME=eks-edu-workload-policy-${IDE_NAME}
ROLE_NAME=eks-edu-workload-role-${IDE_NAME}
NAMESPACE_NAME=default
# ==================================================================

cat >pod-identity-deployment.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pod-identity-app
spec:
  selector:
    matchLabels:
      app: pod-identity-app
  template:
    metadata:
      labels:
        app: pod-identity-app
    spec:
      serviceAccountName: ${SERVICE_ACCOUNT_NAME}
      containers:
      - name: my-app
        image: public.ecr.aws/nginx/nginx:1.27
EOF

kubectl apply -f pod-identity-deployment.yaml
