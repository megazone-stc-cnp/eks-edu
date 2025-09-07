#!/bin/bash

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <LAUNCHTEMPLATE_ID> <SOURCE LAUNCHTEMPLATE_VERSION>"
  exit 1
fi

LAUNCHTEMPLATE_ID=$1
LAUNCHTEMPLATE_VERSION=$2

if [ ! -f "../../env.sh" ];then
  echo "env.sh 파일 세팅을 해주세요."
  exit 1
fi
. ../../env.sh

if [ ! -f "tmp/launch-template.json" ];then
	echo "tmp/launch-template.json 파일 세팅을 해주세요."
	exit 1
fi
# ==================================================================

TEMPLATE_DATA=$(cat tmp/launch-template.json)

aws ec2 create-launch-template-version \
    --launch-template-id ${LAUNCHTEMPLATE_ID} \
    --source-version ${LAUNCHTEMPLATE_VERSION} \
    --launch-template-data "${TEMPLATE_DATA}" \
    --version-description "Change Version" \
    --profile ${PROFILE_NAME} --region ${REGION_NAME}

