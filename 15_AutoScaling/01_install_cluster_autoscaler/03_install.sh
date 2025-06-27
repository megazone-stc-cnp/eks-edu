#!/bin/bash

if [ -z "$1" ]; then
    echo "사용법: $0 <CHART_VERSION>"
    exit 1
fi
CHART_VERSION=$1

if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

REPO_NAME=autoscaler
CHART_NAME=cluster-autoscaler
NAMESPACE_NAME=kube-system
APP_NAME=cluster-autoscaler
SERVICE_ACCOUNT_NAME=cluster-autoscaler-sa
ROLE_NAME="cluster-autoscaler-role-${IDE_NAME}"
# ==================================================================
if [ ! -d "tmp" ]; then
    mkdir -p tmp
fi

cat > tmp/cluster_autoscaler_value.yaml<<EOF
autoDiscovery:
  clusterName: ${CLUSTER_NAME}
awsRegion: ${AWS_REGION}
containerSecurityContext:
  capabilities:
    drop:
    - ALL
extraArgs:
  logtostderr: true
  stderrthreshold: info
  v: 4
  skip-nodes-with-local-storage: false
  expander: least-waste
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
  repository: registry.k8s.io/autoscaling/cluster-autoscaler
  tag: v${EKS_VERSION}.0
rbac:
  create: true
  pspEnabled: false
  serviceAccount:
    annotations:
      eks.amazonaws.com/role-arn: arn:aws:iam::${AWS_REPO_ACCOUNT}:role/${ROLE_NAME}
    automountServiceAccountToken: true
    create: true
    name: ${SERVICE_ACCOUNT_NAME}
replicaCount: 1
resources:
  limits:
    cpu: 100m
    memory: 600Mi
  requests:
    cpu: 100m
    memory: 600Mi
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

helm upgrade --install ${APP_NAME} ${REPO_NAME}/${CHART_NAME} \
  --version "${CHART_VERSION}" \
  --namespace ${NAMESPACE_NAME} \
  --wait