# 학습 목표
- ECR의 사용법을 이해하고, pull through cache 사용법을 익힌다. 

# 학습 절차
## 사전 조건
- docker가 설치되어 있어야 한다. ( 01_Container/04_install_docker.sh )
## 실습
1. ECR에 이미지 입로드
```
# 대상

# ECR 생성
```
2. pull through cache 생성
```
aws ecr create-pull-through-cache-rule \
  --name my-cache-rule \
  --upstream-registry-url registry-1.docker.io \
  --ecr-repository-prefix my-cache
```
## 리소스 삭제