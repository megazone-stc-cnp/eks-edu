#!/bin/bash

cd ../../03_Default_Environment/01_create_vpc

# VPC 생성
bash 01_default_vpc.sh

# CloudFormat의 Output 정보 출력
bash 02_get_output.sh

cd ../02_create_eks

bash 01-2_make_eksctl_cluster_nodegroup_full_template.sh

bash 02_eksctl_install.sh

cd ../../12_Storage_Management/00_pre_setup