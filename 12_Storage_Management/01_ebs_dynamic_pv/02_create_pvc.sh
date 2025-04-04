#!/bin/bash

STORAGECLASS_NAME=ebs-dynamic-sc
PVC_NAME=ebs-dynamic-claim
# ====================================================================
if [ ! -d "tmp" ]; then
    mkdir -p tmp
fi

cat > tmp/ebs_dynamic_pvc.yaml<<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ${PVC_NAME}
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: ${STORAGECLASS_NAME}
  resources:
    requests:
      storage: 1Gi
EOF

echo "kubectl apply -f tmp/ebs_dynamic_pvc.yaml"
kubectl apply -f tmp/ebs_dynamic_pvc.yaml

kubectl get pvc