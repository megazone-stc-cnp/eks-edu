#!/bin/bash
if [ -z "$1" ]; then
    echo "사용법: $0 <VOLUME_ID>"
    exit 1
fi
VOLUME_ID=$1

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
  name: test-pv
spec:
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: ${VOLUME_SIZE}Gi
  csi:
    driver: ebs.csi.aws.com
    fsType: ext4
    volumeHandle: ${VOLUME_ID}
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
            - key: topology.kubernetes.io/zone
              operator: In
              values:
                - ${AWS_AZ1}
EOF

echo "kubectl apply -f tmp/ebs_pv.yaml"
kubectl apply -f tmp/ebs_pv.yaml

kubectl get pv