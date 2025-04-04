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

cat > tmp/ebs_pvc.yaml<<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: efs-claim
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: efs-sc
  resources:
    requests:
      storage: 5Gi
EOF

echo "kubectl apply -f tmp/ebs_pvc.yaml"
kubectl apply -f tmp/ebs_pvc.yaml

kubectl get pvc