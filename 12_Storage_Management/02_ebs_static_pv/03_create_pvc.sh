#!/bin/bash

PV_NAME=ebs-static-pv
PVC_NAME=ebs-static-claim
VOLUME_SIZE="1"
# ====================================================================
if [ ! -d "tmp" ]; then
    mkdir -p tmp
fi

cat > tmp/ebs_static_pvc.yaml<<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ${PVC_NAME}
spec:
  storageClassName: "" # Empty string must be explicitly set otherwise default StorageClass will be set
  volumeName: ${PV_NAME}
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: ${VOLUME_SIZE}Gi
EOF

echo "kubectl apply -f tmp/ebs_static_pvc.yaml"
kubectl apply -f tmp/ebs_static_pvc.yaml

kubectl get pvc