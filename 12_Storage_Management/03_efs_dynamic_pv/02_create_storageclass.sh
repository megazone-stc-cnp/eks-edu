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

cat > tmp/ebs_storageclass.yaml<<EOF
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: efs-sc
provisioner: efs.csi.aws.com
parameters:
  provisioningMode: efs-ap
  fileSystemId: fs-92107410
  directoryPerms: "700"
  gidRangeStart: "1000" # optional
  gidRangeEnd: "2000" # optional
  basePath: "/dynamic_provisioning" # optional
  subPathPattern: "${.PVC.namespace}/${.PVC.name}" # optional
  ensureUniqueDirectory: "true" # optional
  reuseAccessPoint: "false" # optional
EOF

echo "kubectl apply -f tmp/ebs_storageclass.yaml"
kubectl apply -f tmp/ebs_storageclass.yaml

kubectl get storageclass