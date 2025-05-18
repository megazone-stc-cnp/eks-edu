#!/bin/bash
if [ ! -f "../../env.sh" ];then
    echo "env.sh 파일 세팅을 해주세요."
    exit 1
fi
. ../../env.sh

if [ ! -f "../04_target_group_binding/local_env.sh" ];then
	echo "../04_target_group_binding/local_env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../04_target_group_binding/local_env.sh
# export NLB_SECURITY_GROUP_ID=
# export TARGET_GROUP_ARN=
# export LISTENER_ARN=
# export NLB_ARN=
# =============================================================================
# NLB 리소스 삭제 프로세스 시작
echo "NLB 리소스 삭제를 시작합니다..."

# 리스너 삭제
if [ ! -z "${LISTENER_ARN}" ]; then
    echo "리스너 삭제 중: ${LISTENER_ARN}"
    aws elbv2 delete-listener \
        --listener-arn ${LISTENER_ARN} ${PROFILE_STRING}
    
    if [ $? -eq 0 ]; then
        echo "리스너가 성공적으로 삭제되었습니다."
    else
        echo "리스너 삭제에 실패했습니다."
    fi
else
    echo "리스너 ARN이 설정되지 않았습니다."
fi

# 타겟 그룹 삭제
if [ ! -z "$TARGET_GROUP_ARN" ]; then
    echo "타겟 그룹 삭제 중: ${TARGET_GROUP_ARN}"
    aws elbv2 delete-target-group \
        --target-group-arn ${TARGET_GROUP_ARN} ${PROFILE_STRING}
    
    if [ $? -eq 0 ]; then
        echo "타겟 그룹이 성공적으로 삭제되었습니다."
    else
        echo "타겟 그룹 삭제에 실패했습니다."
    fi
else
    echo "타겟 그룹 ARN이 설정되지 않았습니다."
fi

# NLB 삭제
if [ ! -z "$NLB_ARN" ]; then
    echo "NLB 삭제 중: ${NLB_ARN}"
    aws elbv2 delete-load-balancer \
        --load-balancer-arn ${NLB_ARN} ${PROFILE_STRING}
    
    if [ $? -eq 0 ]; then
        echo "NLB가 성공적으로 삭제되었습니다."
    else
        echo "NLB 삭제에 실패했습니다."
    fi
else
    echo "NLB ARN이 설정되지 않았습니다."
fi

# 보안 그룹 삭제
if [ ! -z "$NLB_SECURITY_GROUP_ID" ]; then
    echo "보안 그룹 삭제 중: ${NLB_SECURITY_GROUP_ID}"
    aws ec2 delete-security-group \
        --group-id ${NLB_SECURITY_GROUP_ID} ${PROFILE_STRING}
    
    if [ $? -eq 0 ]; then
        echo "보안 그룹이 성공적으로 삭제되었습니다."
    else
        echo "보안 그룹 삭제에 실패했습니다."
    fi
else
    echo "보안 그룹 ID가 설정되지 않았습니다."
fi

echo "NLB 리소스 삭제 프로세스가 완료되었습니다."
