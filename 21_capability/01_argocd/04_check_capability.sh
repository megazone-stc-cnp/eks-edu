#!/bin/bash

if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

ARGOCD_CAPABILITY_ROLE_NAME=eks-edu-argocd-capability-role-${IDE_NAME}
CAPABILITY_NAME=argocd-${IDE_NAME}
CHECK_INTERVAL=2
elapsed_time=0
# ==============================================================
echo "aws eks describe-capability \\
  --region ${AWS_REGION} \\
  --cluster-name ${CLUSTER_NAME} \\
  --capability-name ${CAPABILITY_NAME} \\
  --query 'capability.status' \\
  --output text ${PROFILE_STRING}"

while true; do
    STATUS=$(aws eks describe-capability \
    --region ${AWS_REGION} \
    --cluster-name ${CLUSTER_NAME} \
    --capability-name ${CAPABILITY_NAME} \
    --query 'capability.status' \
    --output text ${PROFILE_STRING} 2>&1)

    # 에러 체크
    if [[ $? -ne 0 ]]; then
      echo "Error checking capability status: ${STATUS}"
      exit 1
    fi

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Current status: ${STATUS} (elapsed: ${elapsed_time}s)"

    # ACTIVE 상태 확인
    if [[ "${STATUS}" == "ACTIVE" ]]; then
      echo "✓ Capability is now ACTIVE!"
      exit 0
    fi

    # FAILED 상태 확인
    if [[ "${STATUS}" == "FAILED" ]] || [[ "${STATUS}" == "DELETE_FAILED" ]]; then
      echo "✗ Capability is in ${STATUS} state. Exiting."
      exit 1
    fi

    # 대기
    sleep ${CHECK_INTERVAL}
    elapsed_time=$((elapsed_time + CHECK_INTERVAL))
done