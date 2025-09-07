#!/bin/bash

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <LAUNCHTEMPLATE_ID> <LAUNCHTEMPLATE_VERSION>"
  exit 1
fi

EXIT_LAUNCHTEMPLATE_ID=$1
EXIT_LAUNCHTEMPLATE_VERSION=$2

echo "LAUNCHTEMPLATE_ID: ${EXIT_LAUNCHTEMPLATE_ID}"
echo "LAUNCHTEMPLATE_VERSION: ${EXIT_LAUNCHTEMPLATE_VERSION}"

if [ ! -f "../../env.sh" ];then
  echo "env.sh 파일 세팅을 해주세요."
  exit 1
fi
. ../../env.sh

# ==================================================================
if [ ! -d "tmp" ]; then
    mkdir -p tmp
fi

echo aws ec2 describe-launch-template-versions --launch-template-id "$EXIT_LAUNCHTEMPLATE_ID" --versions "$EXIT_LAUNCHTEMPLATE_VERSION" --query "LaunchTemplateVersions[0].LaunchTemplateData" --profile ${PROFILE_NAME} --region ${REGION_NAME} --output json

TEMPLATE_DATA=$(aws ec2 describe-launch-template-versions \
  --launch-template-id "$EXIT_LAUNCHTEMPLATE_ID" \
  --versions "$EXIT_LAUNCHTEMPLATE_VERSION" \
  --query "LaunchTemplateVersions[0].LaunchTemplateData" \
  --profile ${PROFILE_NAME} --region ${REGION_NAME} \
  --output json)

rm -rf tmp/launch-template.json
echo ${TEMPLATE_DATA} | jq | tee tmp/launch-template.json 
