#!/bin/bash

if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

REPOSITORY_PREFIX=public-ecr-${IDE_NAME}
# ==================================================================

echo "aws ecr create-pull-through-cache-rule \\
  --upstream-registry-url public.ecr.aws \\
  --ecr-repository-prefix ${REPOSITORY_PREFIX} ${PROFILE_STRING}"

aws ecr create-pull-through-cache-rule \
  --upstream-registry-url public.ecr.aws \
  --ecr-repository-prefix ${REPOSITORY_PREFIX} ${PROFILE_STRING}