# 1. 목표
## 1-1. Pod에 AWS 리소스 접근 권한을 부여할 수 있다.

# 2. 이론
## 2-1. IRSA
### 2-1-1. IRSA란?
- Pod의 컨테이너에 있는 애플리케이션은 AWS SDK 또는 AWS CLI를 사용하여 AWS ID 및 액세스 관리(IAM) 권한을 사용하여 AWS 서비스에 API 요청을 할 수 있다.
- 애플리케이션은 AWS 자격 증명으로 AWS API 요청에 서명해야 합니다.
- 서비스 계정에 대한 IAM 역할(IRSA)은 Amazon EC2 인스턴스 프로파일이 Amazon EC2 인스턴스에 자격 증명을 제공하는 것과 비슷한 방식으로 애플리케이션에 대한 자격 증명을 관리하는 기능을 제공합니다.
- AWS 자격 증명을 생성하여 컨테이너에 배포하거나 Amazon EC2 인스턴스의 역할을 사용하는 대신에 IAM 역할을 Kubernetes 서비스 계정과 연결하고 서비스 계정을 사용하도록 포드를 구성합니다.
### 2-1-2. 이점
- 최소 권한 : IAM 권한의 범위를 서비스 계정으로 지정할 수 있습니다. 그러면 해당 서비스 계정을 사용하는 포드만 이 권한에 액세스 할 수 있습니다. 또한 이 기능을 사용하면 kiam, kube2iam 같은 타사 솔루션이 필요 없습니다.
- 자격 증명 격리 : 포드의 컨테이너는 컨테이너가 사용하는 서비스 계정과 연결된 IAM 역할에 대한 자격증명만 검색할 수 있습니다. 컨테이너는 다른 포드의 다른 컨테이너에서 사용하는 자격 증명에 액세스할 수 없습니다. 서비스 계정에 IAM 역할을 사용하는 경우 Amazon EC2 인스턴스 메타데이터 서비스(IMDS)에 대한 포드 액세스를 차단하지 않는 한 컨테이너에도 Amazon EKS 노드 IAM 역할에 할당된 권한이 있습니다.
- 감사 : AWS CloudTrail을 통한 액세스 및 이벤트 로깅을 사용하여 사후 감사를 지원합니다.

## 2-2. Pod Identity
### 2-2-1. Pod Identity란?
- 각 EKS Pod Identity 연결은 지정된 클러스터의 네임스페이스에 있는 서비스 계정에 역할을 매핑합니다.
- 여러 클러스터에 동일한 애플리케이션이 있는 경우 역할의 신뢰 정책을 수정하지 않고도 각 클러스터에서 동일한 연결을 만들수 있습니다.
- 포드가 연결이 있는 서비스 계정을 사용하는 경우 Amazon EKS는 포드의 컨테이너에 환경 변수를 설정합니다.
- 환경 변수는 AWS CLI를 포함한 AWS SDK를 구성하여 EKS 포드 ID 자격 증명을 사용합니다.

### 2-2-2. Pod Identity 이점
- 최소 권한 : IAM 권한을 서비스 계정으로 범위 지정할 수 있으며, 해당 서비스 계정을 사용하는 Pod만 해당 권한에 액세스할 수 있습니다. 이 기능은 타사 솔루션의 필요성도 없애줍니다.
- 자가 증명 격리 : Pod의 컨테이너는 컨테이너가 사용하는 서비스 계정과 연결된 IAM 역할에 대한 자격 증명만 검색할 수 있습니다. 컨테이너는 다른 Pod의 다른 컨테이너에서 사용하는 자격 증명에 액세스할 수 없습니다. Pod ID를 사용할 때 Pod의 컨테이너는 Amazon EC2 Instance Metadata Service(IMDS) 에 대한 Pod 액세스를 차단하지 않는 한 Amazon EKS 노드 IAM 역할 에 할당된 권한도 갖습니다 .
- 감사 가능성 : AWS CloudTrail을 통해 액세스 및 이벤트 로깅이 가능하여 회고적 감사를 용이하게 할 수 있습니다.

# 3. 사전 조건
## 3-1. 인프라 구성
```
sh 02_Default_Environment/01_default_vpc.sh

```
# 4. 실습
## 4-1. IRSA
## 4-2. Pod Identity
## 4-3. IRSA에서 Pod Identity Migration
# 5. 관련 링크
- [서비스 계정에 대한 IAM 역할](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/iam-roles-for-service-accounts.html)
- [EKS Pod Identity가 포드에 AWS 서비스에 대한 액세스 권한을 부여하는 방법 알아보기](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/pod-identities.html)