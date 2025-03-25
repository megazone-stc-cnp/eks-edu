# Access 관리
## 1. 목표
- 애플리케이션 또는 사용자가 Kubernetes API에 인증할 수 있도록 하는 방법 숙지
## 2. 사전 요구 사항
1. VSCode Server 생성
```shell
01_Container/01_create_vscode_server.sh 
```
2. 기본 VPC 생성
```shell
02_Default_Environment/01_default_vpc.sh
```
3. EKS 구축
```
02_Default_Environment/03_make_eksctl_template.sh
02_Default_Environment/04_eksctl_install.sh
```
## 3. 이론
### 3.1 Configmap

### 3.2 EKS Access Entry란 ?
- EKS 액세스 항목은 Kubernetes 권한 세트를 IAM 역할과 같은 IAM 자격 증명에 연결

### 3.3 Access Entry Permision ([액세스 정책 권한 검토](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/access-policy-permissions.html))
| Permission Type | Description |
|----------------|-------------|
| AmazonEKSAdminPolicy | 리소스에 대한 대부분의 권한을 IAM 보안 주체에 부여하는 권한이 포함 |
| AmazonEKSClusterAdminPolicy | 클러스터에 대한 액세스 권한을 IAM 보안 주체 관리자에게 부여하는 권한이 포함 |
| AmazonEKSAdminViewPolicy | 클러스터의 모든 리소스를 나열하고 볼 수 있는 권한을 IAM 보안 주체에 부여하는 권한이 포함 |
| AmazonEKSEditPolicy | IAM 위탁자가 대부분의 Kubernetes 리소스를 편집할 수 있는 권한이 포함 |
| AmazonEKSViewPolicy | IAM 위탁자가 대부분의 Kubernetes 리소스를 볼 수 있는 권한이 포함 |
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

### 3.3 ClusterRole/ClusterRoleBinding 과 Role/RoleBinding
1. ClusterRole/ClusterRoleBinding 이란
2. Role/RoleBinding 이란
## 4. 실습
### 4.1 Kubeconfig 파일을 생성하여 kubectl을 EKS 클러스터에 연결
```
sh 01_update_kubeconfig.sh
```
### 4.2 configmap 실습
```
kubectl -n kube-system get configmap aws-auth -oyaml
# 편집
kubectl -n kube-system edit configmap aws-auth
```
### 4.3 ClusterRole/ClusterRoleBinding 실습
1. User 생성
```
```
2. User에 Access Key 발급
3. ClusterRole/Role 생성
4. 권한 설정
### 4.3 ConfigMap에서 Access Entry Migration
1. https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/migrating-access-entries.html
## 5. 리소스 삭제
1. EKS 삭제
```
```
2. 기본 VPC 삭제
```
```
3. VS Code Server 삭제
```
cd 02_Default_Environment
sh 0
```