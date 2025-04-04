#!/bin/bash
if [ -z "$1" ]; then
    echo "사용법: $0 <EFS_ID>"
    exit 1
fi
EFS_ID=$1

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

STORAGECLASS_NAME=efs-static-sc
PV_NAME=efs-static-pv
VOLUME_SIZE="1"
# ====================================================================
if [ ! -d "tmp" ]; then
    mkdir -p tmp
fi

cat > tmp/efs_static_pv.yaml<<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: ${PV_NAME}
spec:
  capacity:
    storage: ${VOLUME_SIZE}Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  storageClassName: ${STORAGECLASS_NAME}
  persistentVolumeReclaimPolicy: Retain
  csi:
    driver: efs.csi.aws.com
    volumeHandle: ${EFS_ID}
EOF

echo "kubectl apply -f tmp/efs_static_pv.yaml"
kubectl apply -f tmp/efs_static_pv.yaml

kubectl get pv