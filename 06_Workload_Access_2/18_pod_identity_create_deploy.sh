#!/bin/bash

if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh
# export AWS_REGION=
# export EMPLOY_ID=
# export PROFILE_NAME=
# export AWS_REPO_ACCOUNT=

SERVICE_ACCOUNT_NAME=eks-edu-pod-identity-service-account-${EMPLOY_ID}
POLICY_NAME=eks-edu-workload-policy-${EMPLOY_ID}
ROLE_NAME=eks-edu-workload-role-${EMPLOY_ID}
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
