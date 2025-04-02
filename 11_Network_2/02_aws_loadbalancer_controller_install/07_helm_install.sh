#!/bin/bash
if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh
# export AWS_REGION=ap-northeast-1
# export IDE_NAME=9641173
# export PROFILE_NAME=cnp-key
# export AWS_REPO_ACCOUNT=539666729110
# export HOME_DIR=/Users/mzc01-hcseo/00_PARA/01_project/autoever-eks-edu/source/eks-edu
# export EKS_VERSION=1.31
# export CLUSTER_NAME=eks-edu-cluster-${IDE_NAME}

if [ ! -f "./local_env.sh" ];then
	echo "local_env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ./local_env.sh
# export VPC_ID=vpc-09effdadb2d737300
# export AWS_AZ1=ap-northeast-1a
# export AWS_AZ2=ap-northeast-1c
# export AWS_PRIVATE_SUBNET1=subnet-03ed17397746222a8
# export AWS_PRIVATE_SUBNET2=subnet-07873917f6e87880b
# export EKS_ADDITIONAL_SG=sg-033a4c5fa9437d100

NAMESPACE_NAME=kube-system
SERVICE_ACCOUNT_NAME=alb-controller-sa
ROLE_NAME=eks-edu-aws-load-balancer-controller-role-${IDE_NAME}
REPO_FULLPATH=public.ecr.aws/eks/aws-load-balancer-controller
ORIGIN_TAG=v2.9.2
# =============================================================================
if [ ! -d "tmp" ]; then
    mkdir -p tmp
fi

cat >tmp/values.yaml <<EOF
affinity:
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
    - podAffinityTerm:
        labelSelector:
          matchExpressions:
          - key: app.kubernetes.io/name
            operator: In
            values:
            - aws-load-balancer-controller
        topologyKey: kubernetes.io/hostname
      weight: 100
clusterName: ${CLUSTER_NAME}
enableShield: false
enableWaf: true
enableWafv2: true
image:
  pullPolicy: IfNotPresent
  repository: ${AWS_REPO_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO_FULLPATH}
  tag: ${ORIGIN_TAG}
ingressClass: alb
podDisruptionBudget:
  minAvailable: 1
region: ${AWS_REGION}
replicaCount: 2
resources:
  limits:
    cpu: 100m
    memory: 150Mi
  requests:
    cpu: 70m
    memory: 70Mi
serviceAccount:
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::${AWS_REPO_ACCOUNT}:role/${ROLE_NAME}
  automountServiceAccountToken: true
  create: true
  name: ${SERVICE_ACCOUNT_NAME}
serviceMonitor:
  additionalLabels: {}
  enabled: false
  interval: 30s
topologySpreadConstraints:
- labelSelector:
    matchLabels:
      app.kubernetes.io/name: aws-load-balancer-controller
  maxSkew: 1
  topologyKey: topology.kubernetes.io/zone
  whenUnsatisfiable: DoNotSchedule
vpcId: ${VPC_ID}
EOF

echo "helm install aws-load-balancer-controller eks/aws-load-balancer-controller \\
  -n ${NAMESPACE_NAME} \\
  -f tmp/values.yaml"

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n ${NAMESPACE_NAME} \
  -f tmp/values.yaml

kubectl get pods -n kube-system  

