#!/bin/bash

# argocd 명령어 존재 확인
if command -v argocd &> /dev/null; then
    echo "argocd 명령어가 설치되어 있습니다."
    argocd version
else
    echo "argocd 명령어를 찾을 수 없습니다."
    exit 1
fi