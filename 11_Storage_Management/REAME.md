# 1. 목표
- Storage Class, Persistence Volume, Persistence Volume Claim 에 대해서 배웁니다.
- Dynamic PV와 Static PV에 대해서 배웁니다.
# 2. 사전 조건

# 3. 이론
## 3-1. EBS
### 3-1-1 EBS CSI Driver란?
Amazon Elastic Block Store(Amazon EBS) CSI(Container Storage Interface) 드라이버에서는 Amazon EBS 볼륨의 수명 주기를 사용자가 생성하는 Kubernetes 볼륨의 스토리지로 관리합니다.

Amazon EBS CSI 드라이버는 Amazon EBS 볼륨을 Kubernetes 볼륨 유형인 일반 임시 볼륨 및 영구 볼륨에 사용할 수 있도록 만듭니다.

### 3-1-2 [고려 사항](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/ebs-csi.html#ebs-csi-considerations) 
- Amazon EBS CSI 컨트롤러를 EKS Auto Mode 클러스터에 설치할 필요가 없습니다.
- Amazon EBS 볼륨을 Fargate 포드에 탑재할 수 없습니다.
- Amazon EBS CSI 컨트롤러는 Fargate 노드에서 실행할 수 있지만 Amazon EBS CSI 노드 DaemonSet은(는) Amazon EC2 인스턴스에서만 실행할 수 있습니다.
- Amazon EBS 볼륨 및 Amazon EBS CSI 드라이버는 Amazon EKS Hybrid Nodes와 호환되지 않습니다.
- 최신 추가 기능 버전과 하나의 이전 버전에 대한 지원이 제공됩니다. 최신 버전에서 발견된 버그나 취약성은 새 마이너 버전의 이전 릴리스로 백포트됩니다.
- ebs.csi.eks.amazonaws.com을 프로비저너로 사용하여 스토리지 클래스에서 생성된 플랫폼 버전만 EKS 자동 모드에서 생성한 노드에 탑재할 수 있습니다. 볼륨 스냅샷을 사용하여 기존 플랫폼 버전을 새 스토리지 클래스로 마이그레이션해야 합니다.

### 3-1-3 설치
06_EKS_Cluster_Addon_Irsa/03_ebs_addon 또는 06_EKS_Cluster_Addon_PodIdentity/04_ebs_addon 폴더 참조

## 3-2. EFS
### 3-2-1 EFS CSI Driver란?
Amazon Elastic File System(Amazon EFS)은 완전히 탄력적인 서버리스 파일 스토리지를 제공하므로 스토리지 용량과 성능을 프로비저닝하거나 관리하지 않고도 파일 데이터를 공유할 수 있습니다.

Amazon EBS 컨테이너 스토리지 인터페이스(CSI) 드라이버는 AWS에서는 Kubernetes 클러스터가 Amazon EFS 파일 시스템의 수명 주기를 관리할 수 있게 해주는 CSI 인터페이스를 제공합니다.

## 3-2-2 [고려 사항](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/efs-csi.html#efs-csi-considerations)
- Amazon EFS CSI 드라이버는 **Windows 기반 컨테이너 이미지와 호환되지 않습**니다.
- **Fargate 노드에는 영구 볼륨에 대해 동적 프로비저닝을 사용할 수 없지**만 정적 프로비저닝은 사용할 수 있습니다.
- 동적 프로비저닝은 1.2 이상의 드라이버가 필요합니다. 모든 지원되는 Amazon EKS 클러스터 버전에서 드라이버 버전 1.1을 사용하여 영구 볼륨에 대해 정적 프로비저닝을 사용할 수 있습니다.
- 이 드라이버의 버전 **1.3.2 이상은 Amazon EC2 Graviton 기반 인스턴스를 포함하여 Arm64 아키텍처를 지원**합니다.
- 이 드라이버의 버전 **1.4.2 이상은 파일 시스템 탑재에 FIPS 사용**을 지원합니다.
- Amazon EFS의 리소스 할당량을 기록해 둡니다. 예를 들어, 각 **Amazon EFS 파일 시스템에 대해 생성할 수 있는 액세스 포인트 할당량은 1,000개**입니다.
- 버전 2.0.0부터 이 드라이버는 TLS 연결에 stunnel를 사용하던 것을 efs-proxy로 전환했습니다. efs-proxy를 사용하면 실행 중인 노드의 코어 수에 1을 더한 것과 같은 수의 스레드가 열립니다.
- Amazon EFS CSI 드라이버는 **Amazon EKS Hybrid Nodes와 호환되지 않습**니다.

### 3-1-3 설치
#### 3-1-3-1 AWS CLI 설치
06_EKS_Cluster_Addon_Irsa/04_efs_addon 또는 06_EKS_Cluster_Addon_PodIdentity/05_efs_addon 폴더 참조
#### 3-1-3-2 [AWS Management Console 설치](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/efs-csi.html#efs-create-iam-resources)

### 3-1-4 참고 링크
- [Create an Amazon EFS file system for Amazon EKS](https://github.com/kubernetes-sigs/aws-efs-csi-driver/blob/master/docs/efs-create-filesystem.md)
# 4. 실습
## 4-1. Storage Class 생성
```

```
## 4-1. EBS Dynamic PV
## 4-2. EBS Static PV
## 4-3. EFS Dynamic PV
## 4-3. EFS Static PV
# 5. 정리 