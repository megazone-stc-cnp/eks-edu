#!/bin/bash
if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

if [ ! -f "../../vpc_env.sh" ];then
	echo "01_create_vpc 를 진행해 주세요."
	exit 1
fi
. ../../vpc_env.sh

VOLUME_SIZE="1"
APP_NAME=efs-dynamic-app
PVC_NAME=efs-dynamic-claim
# ====================================================================
if [ ! -d "tmp" ]; then
    mkdir -p tmp
fi

cat > tmp/efs_dynamic_pod.yaml<<EOF
apiVersion: v1
kind: Pod
metadata:
  name: ${APP_NAME}
spec:
  containers:
    - name: app
      image: public.ecr.aws/amazonlinux/amazonlinux
      command: ["/bin/sh"]
      args: ["-c", "while true; do echo $(date -u) >> /data/out; sleep 5; done"]
      volumeMounts:
        - name: persistent-storage
          mountPath: /data
  volumes:
    - name: persistent-storage
      persistentVolumeClaim:
        claimName: ${PVC_NAME}
EOF

echo "kubectl apply -f tmp/efs_dynamic_pod.yaml"
kubectl apply -f tmp/efs_dynamic_pod.yaml

kubectl get pod