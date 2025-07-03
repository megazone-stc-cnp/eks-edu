#!/bin/bash

# ====================================================================
if [ ! -d "tmp" ]; then
    mkdir -p tmp
fi

cat <<EOT > tmp/gp3-storage-class.yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: gp3
allowVolumeExpansion: true
provisioner: ebs.csi.aws.com
volumeBindingMode: WaitForFirstConsumer
parameters:
  type: gp3
  allowAutoIOPSPerGBIncrease: 'true'
  encrypted: 'true'
EOT

kubectl apply -f tmp/gp3-storage-class.yaml