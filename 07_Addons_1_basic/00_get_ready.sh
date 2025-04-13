#!/bin/bash

if [ ! -f "../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../env.sh

EKS_CLUSTER_EXISTED=$(aws eks list-clusters --query "clusters[?@ == '$CLUSTER_NAME']" --output text --no-cli-pager)

if [ -z "$EKS_CLUSTER_EXISTED" ]; then
    echo -e "'$CLUSTER_NAME'에 해당하는 EKS 클러스터가 없습니다.\n'3. 기본 환경 생성'을 이용해 EKS Cluster 생성 후, 다시 시도해 주세요."
    exit 1
fi

ADDON_NAME=eks-node-monitoring-agent
eksctl delete addon --cluster $CLUSTER_NAME --name $ADDON_NAME -v 0 2> /dev/null

ADDON_EXISTED=$(aws eks describe-addon --cluster-name $CLUSTER_NAME --addon-name $ADDON_NAME --query 'addon.addonName' --no-cli-pager --output text 2> /dev/null)
if [ "$ADDON_EXISTED" == $ADDON_NAME ]; then
    echo -e "'Prometheus Node Exporter' Addon이 존재하여 삭제시도했지만 삭제되지 않았습니다. 직접 삭제해 주세요."
    exit 1
else
    echo "준비가 완료되었습니다."
fi
