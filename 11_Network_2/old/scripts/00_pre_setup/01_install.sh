#!/bin/bash

cd ../../02_Default_Environment/

# VPC 생성
bash 01_default_vpc.sh

# CloudFormat의 Output 정보 출력
bash 02_get_output.sh

bash 03_make_eksctl_cluster_nodegroup_template.sh

bash 04_eksctl_install.sh

cd ../03_AWS_Elastic_Container_Registry/

bash 01_create_aws_lbc_ecr_cluster.sh

sleep 5

bash 02_aws_lbc_image_push.sh

cd ../10_Network_2/00_pre_setup