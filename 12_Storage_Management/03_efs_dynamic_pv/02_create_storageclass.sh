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

STORAGECLASS_NAME=efs-dynamic-sc
# ====================================================================
if [ ! -d "tmp" ]; then
    mkdir -p tmp
fi

cat > tmp/efs_dynamic_storageclass.yaml<<EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: __STORAGECLASS_NAME__
provisioner: efs.csi.aws.com
parameters:
  provisioningMode: efs-ap
  fileSystemId: __EFS_ID__
  directoryPerms: "700"
  gidRangeStart: "1000" # optional
  gidRangeEnd: "2000" # optional
  basePath: "/dynamic_provisioning" # optional
  subPathPattern: "\${.PVC.namespace}/\${.PVC.name}" # optional
  ensureUniqueDirectory: "true" # optional
  reuseAccessPoint: "false" # optional
EOF

sed -i "s|__STORAGECLASS_NAME__|$STORAGECLASS_NAME|g" tmp/efs_dynamic_storageclass.yaml
sed -i "s|__EFS_ID__|$EFS_ID|g" tmp/efs_dynamic_storageclass.yaml

echo "kubectl apply -f tmp/efs_dynamic_storageclass.yaml"
kubectl apply -f tmp/efs_dynamic_storageclass.yaml

kubectl get storageclass