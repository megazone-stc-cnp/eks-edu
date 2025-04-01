#!/bin/bash

# ====================================================================
if [ ! -d "tmp" ]; then
    mkdir -p tmp
fi

cat > tmp/gp3_storage_class.yaml<<EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: gp3
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: ebs.csi.aws.com    
volumeBindingMode: WaitForFirstConsumer    
parameters:
  csi.storage.k8s.io/fstype: ext4
  type: gp3
reclaimPolicy: Retain
allowVolumeExpansion: true
EOF

kubectl apply -f tmp/gp3_storage_class.yaml

kubectl get storageclass