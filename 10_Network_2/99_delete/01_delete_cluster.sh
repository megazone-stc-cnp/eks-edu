#!/bin/bash

cd ../../02_Default_Environment/

# eks cluster 삭제
bash 98_delete_cluster.sh

# VPC 삭제
bash 99_delete_vpc.sh

cd ../10_Network_2/99_delete