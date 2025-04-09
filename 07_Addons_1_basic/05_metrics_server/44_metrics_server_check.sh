#!/bin/bash

. ../env.sh

ADDON_NAME=metrics-server
# ================================

aws eks describe-addon \
    --cluster-name ${CLUSTER_NAME} \
    --addon-name ${ADDON_NAME} ${PROFILE_STRING}