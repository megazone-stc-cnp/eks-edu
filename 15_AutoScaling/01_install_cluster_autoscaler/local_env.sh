#!/bin/bash

# 참고할 수 있는 변수
#export AWS_REGION=ap-northeast-1
#export IDE_NAME=9641173
#export AWS_ACCOUNT_ID=539666729110
#
#export HOME_DIR=/Users/mzc01-hcseo/00_PARA/01_project/autoever-eks-edu/source/eks-edu
#export EKS_VERSION=1.32
## =============================================================
## 자동 생성
#export CLUSTER_NAME=eks-edu-cluster-${IDE_NAME}

REPO_URL=https://kubernetes.github.io/autoscaler
REPO_NAME=autoscaler
APP_NAME=cluster-autoscaler
CHART_NAME=cluster-autoscaler
SERVICE_ACCOUNT_NAME=cluster-autoscaler-sa
NAMESPACE_NAME=kube-system
POLICY_JSON=$(cat <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "aws:ResourceTag/k8s.io/cluster-autoscaler/enabled": "true",
                    "aws:ResourceTag/k8s.io/cluster-autoscaler/${CLUSTER_NAME}": "owned"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:DescribeScalingActivities",
                "autoscaling:DescribeTags",
                "ec2:DescribeImages",
                "ec2:DescribeInstanceTypes",
                "ec2:DescribeLaunchTemplateVersions",
                "ec2:GetInstanceTypesFromInstanceRequirements",
                "eks:DescribeNodegroup"
            ],
            "Resource": "*"
        }
    ]
}
EOF
)

HELM_VALUE_YAML=$(cat <<EOF
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
      eks.amazonaws.com/role-arn: arn:aws:iam::${AWS_ACCOUNT_ID}:role/${ROLE_NAME}
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
  path: /metri
EOF
)