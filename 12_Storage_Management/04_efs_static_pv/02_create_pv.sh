#!/bin/bash
if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh

if [ ! -f "../../vpc_env.sh" ];then
	echo "01_create_vpc 를 진행해 주세요."
	exit 1
fi
. ../../vpc_env.sh

PV_NAME=test-pv
VOLUME_SIZE="1"
# ====================================================================
if [ ! -d "tmp" ]; then
    mkdir -p tmp
fi

cat > tmp/ebs_pv.yaml<<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: efs-pv
spec:
  capacity:
    storage: 5Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  storageClassName: efs-sc
  persistentVolumeReclaimPolicy: Retain
  csi:
    driver: efs.csi.aws.com
    volumeHandle: fs-e8a95a42
EOF

echo "kubectl apply -f tmp/ebs_pv.yaml"
kubectl apply -f tmp/ebs_pv.yaml

kubectl get pv