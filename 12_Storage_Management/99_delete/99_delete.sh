#!/bin/bash
if [ ! -f "../../env.sh" ];then
	echo "Root 디렉토리에 env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh
# export AWS_REGION=ap-northeast-1
# export IDE_NAME=9641173
# export PROFILE_NAME=cnp-key
# export HOME_DIR=/Users/mzc01-hcseo/00_PARA/01_project/autoever-eks-edu/source/eks-edu
# export EKS_VERSION=1.31
# export CLUSTER_NAME=eks-edu-cluster-${IDE_NAME}

if [ ! -f "../delete_env.sh" ];then
	echo "상위 디렉토리에 delete_env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../delete_env.sh
# export EBS_VOLUME_ID=vol-0eecb37dc650000cb
# export EFS_SECURITY_GROUP=sg-0bea82704736e1ff2
# export EFS_FILESYSTEM_ID=fs-002c6492a5482f394
# ======================================================
# EBS 볼륨 삭제
if [ ! -z "${EBS_VOLUME_ID}" ]; then
    echo "aws ec2 delete-volume --volume-id ${EBS_VOLUME_ID} ${PROFILE_STRING}"
    echo "EBS 볼륨 삭제 중..."
else
    echo "EBS_VOLUME_ID가 설정되지 않았습니다."
fi

# EFS 마운트 타겟 삭제 (파일 시스템 삭제 전 필요)
if [ ! -z "${EFS_FILESYSTEM_ID}" ]; then
    echo "EFS 마운트 타겟 삭제 중..."
    MOUNT_TARGETS=$(aws efs describe-mount-targets --file-system-id ${EFS_FILESYSTEM_ID} --query "MountTargets[*].MountTargetId" --output text ${PROFILE_STRING})
    
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
if [ ! -z "${EFS_FILESYSTEM_ID}" ]; then
    echo "aws efs delete-file-system --file-system-id ${EFS_FILESYSTEM_ID} ${PROFILE_STRING}"
    echo "EFS 파일 시스템 삭제 중..."
    aws efs delete-file-system --file-system-id ${EFS_FILESYSTEM_ID} ${PROFILE_STRING}
    if [ $? -eq 0 ]; then
        echo "EFS 파일 시스템 삭제 완료"
    else
        echo "EFS 파일 시스템 삭제 실패"
    fi
else
    echo "EFS_FILESYSTEM_ID가 설정되지 않았습니다."
fi


echo "eksctl delete cluster --name ${CLUSTER_NAME} ${PROFILE_STRING}"
echo "EKS 삭제중....."
eksctl delete cluster --name ${CLUSTER_NAME} ${PROFILE_STRING}

aws cloudformation wait stack-delete-complete \
    --stack-name eks-edu-cluster-${IDE_NAME}-cluster ${PROFILE_STRING}
echo "EKS 삭제 완료....."

echo "aws cloudformation delete-stack \\
  --stack-name eks-workshop-vpc-${IDE_NAME} ${PROFILE_STRING}"

aws cloudformation delete-stack \
  --stack-name eks-workshop-vpc-${IDE_NAME} ${PROFILE_STRING}

echo "VPC 삭제중....."
aws cloudformation wait stack-delete-complete \
    --stack-name eks-workshop-vpc-${IDE_NAME} ${PROFILE_STRING}
if [ -f "../../vpc_env.sh" ];then
	rm -rf ../../vpc_env.sh
fi
echo "VPC 삭제 완료....."