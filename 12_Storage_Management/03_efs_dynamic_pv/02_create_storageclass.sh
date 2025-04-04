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

PV_NAME=test-pv
VOLUME_SIZE="1"
STORAGECLASS_NAME=efs-dynamic-sc
# ====================================================================
if [ ! -d "tmp" ]; then
    mkdir -p tmp
fi

cat > tmp/efs_dynamic_storageclass.yaml<<EOF
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: ${STORAGECLASS_NAME}
provisioner: efs.csi.aws.com
parameters:
  provisioningMode: efs-ap
  fileSystemId: ${EFS_ID}
  directoryPerms: "700"
  gidRangeStart: "1000" # optional
  gidRangeEnd: "2000" # optional
  basePath: "/dynamic_provisioning" # optional
  subPathPattern: "${.PVC.namespace}/${.PVC.name}" # optional
  ensureUniqueDirectory: "true" # optional
  reuseAccessPoint: "false" # optional
EOF

echo "kubectl apply -f tmp/efs_dynamic_storageclass.yaml"
kubectl apply -f tmp/efs_dynamic_storageclass.yaml

kubectl get storageclass