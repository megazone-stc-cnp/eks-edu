#!/bin/bash
if [ ! -f "../../env.sh" ];then
	echo "Root 디렉토리에 env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

if [ ! -f "../03_efs_dynamic_pv/local_env.sh" ];then
	echo "local_env.sh 가 존재해야 합니다."
	exit 1
fi
. ../03_efs_dynamic_pv/local_env.sh

# ======================================================
# App 삭제
kubectl delete pod ebs-dynamic-app
kubectl delete pod ebs-static-app
kubectl delete pod efs-dynamic-app
kubectl delete pod efs-static-app

# EBS 볼륨 삭제
volume_ids=$(aws ec2 describe-volumes \
  --filters Name=tag-key,Values="kubernetes.io/created-for/pvc/name" \
  --query "Volumes[*].VolumeId" \
  --output text)

for vid in $volume_ids; do
  echo "🗑️ $vid 삭제 중..."
  aws ec2 delete-volume --volume-id "$vid"
done

# EFS 마운트 타겟 삭제 (파일 시스템 삭제 전 필요)
if [ ! -z "${EFS_ID}" ]; then
    echo "EFS 마운트 타겟 삭제 중..."
    MOUNT_TARGETS=$(aws efs describe-mount-targets --file-system-id ${EFS_ID} --query "MountTargets[*].MountTargetId" --output text ${PROFILE_STRING})
    
    for MT_ID in ${MOUNT_TARGETS}; do
        echo "마운트 타겟 삭제: ${MT_ID}"
        aws efs delete-mount-target --mount-target-id ${MT_ID} ${PROFILE_STRING}
    done
    
    # 모든 마운트 타겟이 삭제될 때까지 대기
    echo "모든 마운트 타겟이 삭제될 때까지 대기 중..."
    sleep 30
fi

# EFS 보안 그룹 삭제
if [ ! -z "${EFS_SECURITY_GROUP}" ]; then
    echo "aws ec2 delete-security-group --group-id ${EFS_SECURITY_GROUP} ${PROFILE_STRING}"
    echo "EFS 보안 그룹 삭제 중..."
    aws ec2 delete-security-group --group-id ${EFS_SECURITY_GROUP} ${PROFILE_STRING}
else
    echo "EFS_SECURITY_GROUP이 설정되지 않았습니다."
fi

# EFS 파일 시스템 삭제
if [ ! -z "${EFS_ID}" ]; then
    echo "aws efs delete-file-system --file-system-id ${EFS_ID} ${PROFILE_STRING}"
    echo "EFS 파일 시스템 삭제 중..."
    aws efs delete-file-system --file-system-id ${EFS_ID} ${PROFILE_STRING}
    if [ $? -eq 0 ]; then
        echo "EFS 파일 시스템 삭제 완료"
    else
        echo "EFS 파일 시스템 삭제 실패"
    fi
else
    echo "EFS_ID 설정되지 않았습니다."
fi
