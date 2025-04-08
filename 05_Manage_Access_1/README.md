# Access 관리

## 사전 조건

1. [0. 교육 환경 구성하기](00_Setup/)를 이용해 기본 실습 환경 생성이 되어 있어야 합니다.
2. [0. 교육 환경 구성하기](00_Setup/)를 이용해 생성된 `code-server`에 접속한 상태여야 합니다.
3. [3. 기본 환경 생성](03_Default_Environment/)에 vpc와 eks를 배포해야 합니다.
   ```shell
   cd ~/environment/eks-edu/03_Default_Environment/01_create_vpc
   sh 01_default_vpc.sh
   sh 02_get_output.sh
   cd ../02_create_eks
   sh 01_make_eksctl_cluster_nodegroup_default_template.sh
   sh 02_eksctl_install.sh
   ```

## 학습 목표
- AWS IAM 사용자가 Kubernetes API에 인증할 수 있도록 하는 방법 숙지 ( IRSA 와 Pod Identity )

## 이론

클러스터에는 Kubernetes API 엔드포인트가 있습니다. Kubectl은 이 API를 사용합니다. 다음 두 유형의 ID를 사용하여 이 API에 인증할 수 있습니다.
- AWS ID 및 액세스 관리(IAM) 보안 주체(역할 또는 사용자)
- 자체 OpenID Connect(OIDC) 제공자의 사용자

### 클러스터 인증 모드 설정
| 인증 모드 | 설명 |
|----------------|-------------|
| ConfigMap만 해당 | 초기 사용자는 **aws-auth ConfigMap**에서 목록에 다른 사용자를 추가하고 클러스터 내 다른 사용자에게 영향을 주는 권한을 할당해야 합니다. |
| EKS API 및 ConfigMap | **두 가지 방법을 모두 사용**하여 클러스터에 IAM 보안 주체를 추가할 수 있습니다. |
| EKS API만 해당 | 각 액세스 항목에는 유형이 있으며, **보안 주체를 특정 네임스페이스로 제한하는 액세스 범위와 사전 구성된 재사용 가능한 권한 정책을 설정하는 액세스 정책을 조합하여 사용**할 수 있습니다. 또는 **STANDARD 유형 및 Kubernetes RBAC 그룹을 사용하여 사용자 지정 권한을 할당**할 수 있습니다. |

### Configmap

**aws-auth ConfigMap는 더 이상 사용되지 않습니다.**

Amazon EKS 클러스터를 생성할 경우, 클러스터를 생성하는 IAM 보안 주체에게는 Amazon EKS 제어 영역의 클러스터 역할 기반 액세스 제어(RBAC) 구성에 system:masters 권한이 자동으로 부여

### 3.2 EKS Access Entry란 ?
- EKS 액세스 항목은 Kubernetes 권한 세트를 IAM 역할과 같은 IAM 자격 증명에 연결

#### 장점
이 기능은 사용자 권한을 관리할 때 AWS 및 Kubernetes API 사이를 전환하지 않아도 되므로 **액세스 관리를 간소화**합니다.

이 기능은 AWS CloudFormation, Terraform 및 AWS CDK와 같은 **코드형 인프라(IaC) 도구와 통합되어 클러스터 생성 중에 액세스 구성을 정의**할 수 있습니다. 잘못 구성된 경우 직접 Kubernetes API에 액세스하지 않고도 Amazon EKS API를 통해 클러스터 액세스를 복원할 수 있습니다. 이러한 **중앙 집중식 접근 방식은 CloudTrail 감사 로깅 및 다중 인증과 같은 기존의 AWS IAM 기능을 활용하여 운영 오버헤드를 줄이고 보안을 개선**합니다.

### Access Entry Permision ([액세스 정책 권한 검토](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/access-policy-permissions.html))
| Permission Type | Description |
|----------------|-------------|
| AmazonEKSAdminPolicy | 리소스에 대한 대부분의 권한을 IAM 보안 주체에 부여하는 권한이 포함 |
| **AmazonEKSClusterAdminPolicy** | 클러스터에 대한 액세스 권한을 IAM 보안 주체 관리자에게 부여하는 권한이 포함 |
| AmazonEKSAdminViewPolicy | 클러스터의 모든 리소스를 나열하고 볼 수 있는 권한을 IAM 보안 주체에 부여하는 권한이 포함 |
| AmazonEKSEditPolicy | IAM 위탁자가 대부분의 Kubernetes 리소스를 편집할 수 있는 권한이 포함 |
| **AmazonEKSViewPolicy** | IAM 위탁자가 대부분의 Kubernetes 리소스를 볼 수 있는 권한이 포함 |
| AmazonEKSAutoNodePolicy | Amazon EKS 구성 요소가 다음 태스크를 완료할 수 있도록 허용하는 다음과 같은 권한이 포함 |
| AmazonEKSBlockStoragePolicy | Amazon EKS가 스토리지 작업에 대한 리더 선택 및 조정 리소스를 관리하는 권한이 포함 |
| AmazonEKSLoadBalancingPolicy | Amazon EKS가 로드 밸런싱을 위한 리더 선택 리소스를 관리하는 권한이 포함 |
| AmazonEKSNetworkingPolicy | Amazon EKS가 네트워킹을 위한 리더 선택 리소스를 관리하는 권한이 포함 |
| AmazonEKSComputePolicy | Amazon EKS가 컴퓨팅 작업을 위한 리더 선택 리소스를 관리하는 권한이 포함 |
| AmazonEKSBlockStorageClusterPolicy | Amazon EKS Auto Mode의 블록 스토리지 기능에 필요한 권한을 부여 |
| AmazonEKSComputeClusterPolicy | Amazon EKS Auto Mode의 컴퓨팅 관리 기능에 필요한 권한을 부여 |
| AmazonEKSLoadBalancingClusterPolicy | Amazon EKS Auto Mode의 로드 밸런싱 기능에 필요한 권한을 부여 |
| AmazonEKSNetworkingClusterPolicy | Amazon EKS Auto Mode의 네트워킹 기능에 필요한 권한을 부여 |
| AmazonEKSHybridPolicy | 클러스터의 노드에 대한 EKS 액세스 권한을 부여하는 권한이 포함 |
| AmazonEKSClusterInsightsPolicy | Amazon EKS Cluster Insights 기능에 대한 읽기 전용 권한을 부여 |

### ClusterRole/ClusterRoleBinding 과 Role/RoleBinding
1. ClusterRole/ClusterRoleBinding 이란
2. Role/RoleBinding 이란

## 실습

### 구성도
![구성도](image/diagram.png)

### 기본 환경 구성

## 관련 링크
- [Full Configuration Format](https://github.com/kubernetes-sigs/aws-iam-authenticator#full-configuration-format)