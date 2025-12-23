#!/bin/bash
if [ ! -f "../../env.sh" ];then
	echo "Root 디렉토리에 env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

# App 삭제
cd ../04_app_deploy
bash 99_delete.sh
cd ../99_delete

# cluster 삭제
cd ../03_register_cluster
bash 99_delete.sh
cd ../99_delete

# github register repository 삭제
cd ../02_github_register_repository
bash 99_delete.sh
cd ../99_delete

# Capability / Role 삭제
#cd ../01_argocd
#bash 99_delete.sh
#cd ../99_delete