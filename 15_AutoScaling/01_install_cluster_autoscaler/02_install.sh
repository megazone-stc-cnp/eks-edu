#!/bin/bash

REPO_NAME=autoscaler
CHART_NAME=cluster-autoscaler
NAMESPACE_NAME=kube-system
APP_NAME=cluster-autoscaler
CLUSTER_AUTOSCALER_CHART_VERSION=
# ==================================================================
if [ ! -d "tmp" ]; then
    mkdir -p tmp
fi

cat > tmp/cluster_autoscaler_value.yaml<<EOF
autoDiscovery:
  clusterName: eks-edu-cluster-9641173
awsRegion: ap-northeast-1
containerSecurityContext:
  capabilities:
    drop:
    - ALL
extraArgs:
  balance-similar-node-groups: true
  expander: least-waste
  logtostderr: true
  skip-nodes-with-local-storage: false
  skip-nodes-with-system-pods: false
  stderrthreshold: info
  v: 4
extraVolumeMounts:
- mountPath: /etc/ssl/certs/ca-certificates.crt
  name: ssl-certs
  readOnly: true
extraVolumes:
- hostPath:
    path: /etc/ssl/certs/ca-bundle.crt
  name: ssl-certs
fullnameOverride: cluster-autoscaler
image:
  repository: 539666729110.dkr.ecr.ap-northeast-1.amazonaws.com/eks/cluster-autoscaler
  tag: v1.32.0
podDisruptionBudget:
  maxUnavailable: 1
rbac:
  create: true
  pspEnabled: false
  serviceAccount:
    annotations:
      eks.amazonaws.com/role-arn: arn:aws:iam::539666729110:role/mzc-an1-hcseo-stg-eks-add-autoscaler-iamrol
    automountServiceAccountToken: true
    create: true
    name: cluster-autoscaler-sa
replicaCount: 1
resources:
  limits:
    cpu: 100m
    memory: 100Mi
  requests:
    cpu: 100m
    memory: 100Mi
securityContext:
  runAsGroup: 1001
  runAsNonRoot: true
  runAsUser: 1001
serviceMonitor:
  enabled: false
  interval: 15s
  namespace: kube-system
  path: /metrics
EOF

if [[ $(helm repo list | grep "^cluster-autoscaler " | wc -l) == 0 ]];then
    helm repo add ${REPO_NAME} https://kubernetes.github.io/autoscaler
fi
helm repo update

helm upgrade --install ${APP_NAME} ${REPO_NAME}/${CHART_NAME} \
  --version "${CLUSTER_AUTOSCALER_CHART_VERSION}" \
  --namespace ${NAMESPACE_NAME} \
  --wait