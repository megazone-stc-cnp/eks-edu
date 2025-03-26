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
## 2-4 참고 링크
- [관리형 노드 그룹을 사용한 노드 수명 주기 간소화](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/managed-node-groups.html)
- [자체 관리형 노드로 노드 직접 유지](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/worker.html)


# 3. 사전 조건
# 4. 실습
## 4-1. Managed Node Group 생성
### 4-1-1. AWS Management Console 실행
- [AWS Management Console로 노드 그룹 생성](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/create-managed-node-group.html#console_create_managed_nodegroup)
### 4-1-1. 스크립트 실행
```
# VPC 설정 정보 읽어오기
sh 01_get_output.sh

# nodegroup 생성시 설정 정보 변경
vi 02_create_nodegroup.sh

# nodegroup 생성
sh 02_create_nodegroup.sh
```
## 4-2. Pod 배포 (2개 MNG에서 Selector를 이용한 Pod 배포)
# 5. 정리
```
sh 99_delete_nodegroup.sh
```