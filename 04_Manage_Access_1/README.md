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
02_Default_Environment/01_default_infra.sh
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