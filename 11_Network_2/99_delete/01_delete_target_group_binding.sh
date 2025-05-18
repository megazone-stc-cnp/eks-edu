#!/bin/bash
if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

if [ ! -f "../../vpc_env.sh" ];then
	echo "vpc_env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../vpc_env.sh

TARGET_GROUP_BINDING_NAME=eks-edu-target-group-binding-${IDE_NAME}
# =========================================================================================
kubectl delete -f ../04_target_group_binding/tmp/${TARGET_GROUP_BINDING_NAME}.yaml