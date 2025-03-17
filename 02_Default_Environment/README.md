# 학습 목표
- 강의 진행을 위해 기본 인프라 및 EKS Cluster 생성에 대해 익숙해 지기 위한 생성 실습

# 학습 절차
## 기본 Infra 배포
    - VPC, Public Subnet 2개, Pivate Subnet 2개, IGW, NatGateway
    - 01장 01_create_vscode_server.sh 에서 기본 인프라도 생성

## eksctl
### eksctl이란
- eksclt은 관리형 Kubernetes 서비스인 EKS에서 클러스터를 만들고 관리하기 위해 Weaveworks 에서 만든 CLI Tool
- Weaveworks가 상업중 운영을 중단한다고 하여, 현재는 AWS에서 인수한 상태

### 관련 링크
- https://eksctl.io/