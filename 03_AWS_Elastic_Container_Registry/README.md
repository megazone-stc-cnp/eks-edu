# AWS Elastic Container Registry

## 사전 조건

1. [0. 교육 환경 구성하기](00_Setup/)를 이용해 기본 실습 환경 생성이 되어 있어야 합니다.
2. [0. 교육 환경 구성하기](00_Setup/)를 이용해 생성된 `code-server`에 접속한 상태여야 합니다.
3. [1. Container 기술 일반](01_Container/04_install_docker.sh)를 이용해 Docker가 설치되어 있어야 합니다.

## 학습 목표
- ECR의 사용법을 이해하고, Registry 생성 
- pull through cache 에 배우고, 구축 실습
- aws loadbalancer controller 와 cluster autoscaler 퍼블릭 이미지를 Private ECR에 복사 실습

## 이론
### Amazon Elastic Container Registry란?
Amazon Elastic Container Registry(Amazon ECR)는 안전하고 확장 가능하며 안정적인 **AWS 관리형 컨테이너 이미지 레지스트리 서비스**입니다.

Amazon ECR은 AWS IAM을 사용하여 리소스 기반 권한을 가진 프라이빗 리포지토리를 지원합니다. 따라서 지정된 사용자 또는 Amazon EC2 인스턴스가 컨테이너 리포지토리 및 이미지에 액세스할 수 있습니다.

원하는 CLI를 사용하여 도커 이미지, Open Container Initiative(OCI) 이미지 및 OCI 호환 아티팩트를 푸시, 풀 및 관리할 수 있습니다.

#### Amazon ECR의 기능
- 수명 주기 정책은 리포지토리에 있는 이미지의 수명 주기를 관리하는 데 도움이 됩니다.
- 이미지 스캔은 컨테이너 이미지의 소프트웨어 취약성을 식별하는 데 도움이 됩니다. 각 리포지토리는 푸시 시 스캔하도록 구성할 수 있습니다.
- 교차 리전 및 교차 계정 복제를 통해 이미지를 필요한 곳에 쉽게 배치할 수 있습니다. 

### 필수 IAM 권한
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:BatchCheckLayerAvailability",
                "ecr:BatchGetImage",
                "ecr:GetDownloadUrlForLayer",
                "ecr:GetAuthorizationToken"
            ],
            "Resource": "*"
        }
    ]
}
```

### Pull Through Cache란?

![1743490206925](image/pull_through_cache_architect.png)

풀스루 캐시 규칙을 사용하면 업스트림 레지스트리의 콘텐츠를 Amazon ECR 프라이빗 레지스트리와 동기화할 수 있습니다.

Amazon ECR은 현재 다음 업스트림 레지스트리에 대한 풀스루 캐시 규칙 생성을 지원합니다.
- Amazon ECR Public, Kubernetes 컨테이너 이미지 레지스트리 및 Quay(인증 필요 없음)
- Docker Hub, Microsoft Azure 컨테이너 레지스트리, GitHub 컨테이너 레지스트리 및 GitLab 컨테이너 레지스트리(보안 암호로 AWS Secrets Manager 인증 필요)
- Amazon ECR( AWS IAM 역할을 사용한 인증 필요)
- GitLab 컨테이너 레지스트리의 경우 Amazon ECR은 GitLab의 서비스형 소프트웨어(SaaS) 오퍼링에서만 풀스루 캐시를 지원합니다
====================================================
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