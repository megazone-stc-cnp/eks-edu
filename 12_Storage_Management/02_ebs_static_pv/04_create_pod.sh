#!/bin/bash

PV_NAME=ebs-static-pv
PVC_NAME=ebs-static-claim
VOLUME_SIZE="1"
APP_NAME=ebs-static-app
# ====================================================================
if [ ! -d "tmp" ]; then
    mkdir -p tmp
fi

cat > tmp/ebs_static_pod.yaml<<EOF
apiVersion: v1
kind: Pod
metadata:
  name: ${APP_NAME}
spec:
  containers:
  - name: app
    image: public.ecr.aws/amazonlinux/amazonlinux
    command: ["/bin/sh"]
    args: ["-c", "while true; do echo $(date -u) >> /data/out.txt; sleep 5; done"]
    volumeMounts:
    - name: persistent-storage
      mountPath: /data
  volumes:
  - name: persistent-storage
    persistentVolumeClaim:
      claimName: ${PVC_NAME}
EOF

echo "kubectl apply -f tmp/ebs_static_pod.yaml"
kubectl apply -f tmp/ebs_static_pod.yaml

kubectl get pod