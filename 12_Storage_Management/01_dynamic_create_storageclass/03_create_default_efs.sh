#!/bin/bash

# ====================================================================
if [ ! -d "tmp" ]; then
    mkdir -p tmp
fi

cat > tmp/default_efs_storage_class.yaml<<EOF
allowVolumeExpansion: true
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
  name: default-efs
mountOptions:
- iam
parameters:
  directoryPerms: "700"
  fileSystemId: fs-0be8fa4b0e313c530
  provisioningMode: efs-ap
provisioner: efs.csi.aws.com
reclaimPolicy: Delete
volumeBindingMode: Immediate
EOF

kubectl apply -f tmp/gp3_storage_class.yaml

kubectl get storageclass