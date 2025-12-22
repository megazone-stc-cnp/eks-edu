#!/bin/bash

if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

CAPABILITY_NAME=argocd-${IDE_NAME}

# ==============================================================
# Get ArgoCD server endpoint from the capability
echo "aws eks describe-capability \\
    --region ${AWS_REGION} \\
    --cluster-name ${CLUSTER_NAME} \\
    --capability-name ${CAPABILITY_NAME} \\
    --profile ${AWS_PROFILE}"

# Get the full capability description to find the server endpoint
CAPABILITY_DESC=$(aws eks describe-capability --region ${AWS_REGION} --cluster-name ${CLUSTER_NAME} --capability-name ${CAPABILITY_NAME} --profile ${AWS_PROFILE})

echo "Capability Description:"
echo "$CAPABILITY_DESC"

# # Try to extract server endpoint from different possible paths
ARGOCD_SERVER=$(echo "$CAPABILITY_DESC" | jq -r '.capability.configuration.argoCd.serverUrl // empty' 2>/dev/null)
echo "ArgoCD Server Endpoint: $ARGOCD_SERVER"

# # For AWS managed ArgoCD, we need to use SSO login
CLUSTER_ARN=$(aws eks describe-cluster \
  --region ${AWS_REGION} \
  --name ${CLUSTER_NAME} \
  --query 'cluster.arn' \
  --output text ${PROFILE_STRING})

echo "Cluster ARN: $CLUSTER_ARN"

# # Check if cluster is already registered
# echo "Checking if cluster is already registered..."
if argocd cluster list 2>/dev/null | grep -q "in-cluster"; then
    echo "Cluster 'in-cluster' is already registered. Skipping registration."
else
    echo "Registering cluster with ArgoCD..."
    echo "argocd cluster add $CLUSTER_ARN \\
      --aws-cluster-name $CLUSTER_NAME \\
      --name in-cluster \\
      --project default"
    echo ""

    # Register the cluster using Argo CD CLI
    argocd cluster add $CLUSTER_ARN \
      --aws-cluster-name $CLUSTER_ARN \
      --name in-cluster \
      --project default
fi

# echo "Cluster registration process completed!"
# echo "You can verify the cluster registration by running:"
# echo "argocd cluster list"