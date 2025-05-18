#!/bin/bash
if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

if [ ! -f "../../vpc_env.sh" ];then
	echo "vpc_env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../vpc_env.sh

if [ ! -f "./local_env.sh" ];then
	echo "local_env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ./local_env.sh

TARGET_GROUP_BINDING_NAME=eks-edu-target-group-binding-${IDE_NAME}
NAMESPACE_NAME=default
SERVICE_NAME=nginx-service
#==================================================================
if [ ! -d "tmp" ]; then
    mkdir -p tmp
fi
cat <<EOF  > tmp/${TARGET_GROUP_BINDING_NAME}.yaml
apiVersion: elbv2.k8s.aws/v1beta1
kind: TargetGroupBinding
metadata:
  name: ${TARGET_GROUP_BINDING_NAME}
  namespace: ${NAMESPACE_NAME}
spec:
  serviceRef:
    name: ${SERVICE_NAME}
    port: 80
  targetGroupARN: ${TARGET_GROUP_ARN}
EOF

kubectl apply -f tmp/${TARGET_GROUP_BINDING_NAME}.yaml

kubectl get targetgroupbinding