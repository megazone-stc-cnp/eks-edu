#!/bin/bash

if [[ $# -ne 3 ]]; then
  echo "Usage: $0 <LAUNCHTEMPLATE_NAME> <LAUNCHTEMPLATE_ID> <LAUNCHTEMPLATE_VERSION>"
  exit 1
fi

LAUNCHTEMPLATE_NAME=$1
EXIT_LAUNCHTEMPLATE_ID=$2
EXIT_LAUNCHTEMPLATE_VERSION=$3

echo "LAUNCHTEMPLATE_NAME: ${LAUNCHTEMPLATE_NAME}"
echo "LAUNCHTEMPLATE_ID: ${EXIT_LAUNCHTEMPLATE_ID}"
echo "LAUNCHTEMPLATE_VERSION: ${EXIT_LAUNCHTEMPLATE_VERSION}"

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
aws ec2 create-launch-template \
    --launch-template-name ${LAUNCHTEMPLATE_NAME} \
    --version-description "Cloned from $EXISTING_TEMPLATE_ID version $EXIT_LAUNCHTEMPLATE_VERSION" \
    --launch-template-data "$TEMPLATE_DATA" \
    --region ${AWS_REGION} ${PROFILE_STRING}