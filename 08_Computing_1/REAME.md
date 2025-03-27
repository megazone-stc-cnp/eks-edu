# 1. 목표
- NodeGroup에 대해서 이해하고, NodeGroup을 생성할 수 있어야 합니다.

# 2. 이론
## 2-1. Managed Node Group
### 2-1-1. 설명
Amazon EKS 관리형 노드 그룹은 Amazon EKS Kubernetes 클러스터의 노드(Amazon EC2 인스턴스) 프로비저닝 및 수명 주기 관리를 자동화합니다.

Amazon EKS 관리형 노드 그룹을 사용하면 Kubernetes 애플리케이션을 실행하기 위해 컴퓨팅 용량을 제공하는 Amazon EC2 인스턴스를 별도로 프로비저닝하거나 등록할 필요가 없습니다. 

한 번의 조작으로 클러스터에 대한 노드를 자동으로 생성, 업데이트 또는 종료할 수 있습니다. 

노드 업데이트 및 종료는 자동으로 노드를 드레이닝하여 애플리케이션을 계속 사용할 수 있도록 합니다.


## 2-2. Self Managed Group

## 2-3. NodeSelector 과 Affinity
### NodeSelector
1. deployment에 NodeSelector를 추가하여 특정 Node에 배포
```shell
apiVersion: apps/v1
kind: Deployment
...
    spec:
      nodeSelector:
        role: app  # 이 값이 지정된 노드에서만 Pod가 실행됨
```
2. deployment에 Affinity를 추가하여 특정 Node에 배포
```yaml
apiVersion: apps/v1
kind: Deployment
...
    spec:
      containers:
        - name: nginx
          # Public ECR repository with the cached image
          image: public-ecr/nginx:latest  # 예시로 public-ecr 레포지토리에 캐시된 nginx 이미지 사용
          ports:
            - containerPort: 80
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: role
                    operator: In
                    values:
                      - app  # role=app 라벨이 있는 노드에만 배포
```
## 2-4 참고 링크
- [관리형 노드 그룹을 사용한 노드 수명 주기 간소화](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/managed-node-groups.html)
- [자체 관리형 노드로 노드 직접 유지](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/worker.html)


# 3. 사전 조건
```shell
# vscode내에서 작업 환경
cd ${HOME_DIR}
cd 01_Container
bash 01_create_vscode_server.sh
bash 02_get_output.sh
bash 03_get_password.sh

# Default EKS 환경 세팅
cd ${HOME_DIR}
cd 02_Default_Environment
bash 01_default_vpc.sh
bash 02_get_output.sh
bash 03_make_eksctl_template.sh
bash 04_eksctl_install.sh

# Addon PodIdentity
cd ${HOME_DIR}
cd 06_EKS_Cluster_addon_PodIdentity
bash 01_get_addon.sh
bash 02_pod_identity_check_addon_version.sh
bash 03_pod_identity_create_addon.sh
bash 04_coredns_addon_version.sh
bash 05_coredns_configuration.sh
bash 06_coredns_addon_create.sh
bash 12_kube_proxy_addon_version.sh
bash 13_kube_proxy_configuration.sh
bash 14_kube_proxy_addon_create.sh
bash 22_ebs_write_assume_role_file.sh
bash 23_ebs_create_role.sh
bash 24_ebs_attach_policy.sh
bash 25_ebs_addon_version.sh
bash 26_ebs_configuration.sh
bash 27_ebs_addon_create.sh
bash 32_efs_write_assume_role_file.sh
bash 33_efs_create_role.sh
bash 34_efs_attach_policy.sh
bash 35_efs_addon_version.sh
bash 36_efs_configuration.sh
bash 37_efs_addon_create.sh
bash 41_metrics_server_addon_version.sh
bash 42_metrics_server_configuration.sh
bash 43_metrics_server_addon_create.sh
bash 44_metrics_server_check.sh

# VPC CNI
cd ${HOME_DIR}
cd 07_Network
bash 01_get_output.sh
bash 02_get_vpc_cidr.sh
bash 03_associate_vpc_cidr.sh
bash 04_new_subnet.sh
bash 05_get_subnets.sh
bash 06_get_cluster_security_group.sh
bash 07_write_assume_role_file.sh
bash 08_create_role.sh
bash 09_attach_policy.sh
bash 12_vpc_cni_addon_version.sh
bash 13_vpc_cni_configuration.sh
bash 14_vpc_cni_addon_create.sh
bash 15_vpc_cni_check.sh
```
# 4. 실습
## 4-1. Managed Node Group 생성
```shell
# NodeGroup 생성
cd ${HOME_DIR}
cd 08_Computing_1
bash 01_get_output.sh
bash 02_create_ops_nodegroup.sh
bash 03_create_app_nodegroup.sh
```
### 4-1-1. AWS Management Console 실행
- [AWS Management Console로 노드 그룹 생성](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/create-managed-node-group.html#console_create_managed_nodegroup)

## 4-2. Pod 배포 (2개 MNG에서 Selector를 이용한 Pod 배포)
```shell
# NodeGroup 생성
cd ${HOME_DIR}
cd 08_Computing_1
bash 04_create_deployment.sh
```
# 5. 정리
```
sh 99_delete_nodegroup.sh
```