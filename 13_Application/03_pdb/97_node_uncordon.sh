#!/bin/bash
if [ -z "$1" ]; then
    echo "사용법: $0 <NODE_NAME>"
    exit 1
fi
NODE_NAME=$1

kubectl uncordon ${NODE_NAME}