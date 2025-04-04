#!/bin/bash

PVC_NAME=ebs-dynamic-claim
POD_NAME=ebs-dynamic-app
# ====================================================================
if [ ! -d "tmp" ]; then
    mkdir -p tmp
fi

cat > tmp/ebs_dynamic_pod.yaml<<EOF
apiVersion: v1
kind: Pod
metadata:
  name: ${POD_NAME}
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

echo "kubectl apply -f tmp/ebs_dynamic_pod.yaml"
kubectl apply -f tmp/ebs_dynamic_pod.yaml

kubectl get pod