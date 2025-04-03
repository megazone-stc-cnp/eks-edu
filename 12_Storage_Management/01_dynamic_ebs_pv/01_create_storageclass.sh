#!/bin/bash

STORAGECLASS_NAME=ebs-sc
# ====================================================================
if [ ! -d "tmp" ]; then
    mkdir -p tmp
fi

cat > tmp/ebs_storageclass.yaml<<EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ${STORAGECLASS_NAME}
provisioner: ebs.csi.aws.com
reclaimPolicy: Retain
volumeBindingMode: WaitForFirstConsumer
EOF

echo "kubectl apply -f tmp/ebs_storageclass.yaml"

kubectl apply -f tmp/ebs_storageclass.yaml

kubectl get storageclass