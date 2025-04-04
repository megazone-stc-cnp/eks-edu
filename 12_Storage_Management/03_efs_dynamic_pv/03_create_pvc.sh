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

PVC_NAME=efs-dynamic-claim
VOLUME_SIZE="1"
STORAGECLASS_NAME=efs-dynamic-sc
# ====================================================================
if [ ! -d "tmp" ]; then
    mkdir -p tmp
fi

cat > tmp/efs_dynamic_pvc.yaml<<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ${PVC_NAME}
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: ${STORAGECLASS_NAME}
  resources:
    requests:
      storage: ${VOLUME_SIZE}Gi
EOF

echo "kubectl apply -f tmp/efs_dynamic_pvc.yaml"
kubectl apply -f tmp/efs_dynamic_pvc.yaml

kubectl get pvc