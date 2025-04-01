# 1. 목표
- Fargate에 대해서 이해하고, Fargate를 생성할 수 있어야 합니다.
- Nodegroup에서 Fargate로 전환할 수 있어야 합니다.

# 2. 이론
## 2-1. Fargate
Fargate는 컨테이너에 대한 적정 규모의 온디맨드 컴퓨팅 용량을 제공하는 기술

Fargate를 사용하면 컨테이너를 실행하려면 직접 가상 머신 그룹을 프로비저닝, 구성 또는 크기를 조정할 필요가 없습니다.

따라서 서버 유형을 선택하거나, 노드 그룹을 조정할 시점을 결정하거나, 클러스터 패킹을 최적화할 필요가 없습니다.

Fargate 프로필에서 실행되는 방법을 제어
## 2-2. [Fargate의 고려 사항](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/fargate.html#fargate-considerations)
- Fargate에서 실행되는 각 포드에는 자체 격리 경계가 있습니다. 기본 커널, CPU 리소스, 메모리 리소스 또는 탄력적 네트워크 인터페이스를 다른 포드와 공유하지 않습니다.
- Network Load Balancer 및 Application Load Balancer(ALB)는 IP 대상을 통해서만 Fargate에서 사용할 수 있습니다.
- Fargate 노출 서비스는 대상 유형 IP 모드에서만 실행되고 노드 IP 모드에서는 실행되지 않습니다.
- 포드는 Fargate에서 실행되도록 예약된 시점에 Fargate 프로필과 일치해야 합니다
- Daemonsets는 Fargate에서 지원되지 않습니다. 애플리케이션에 데몬이 필요한 경우 해당 데몬을 재구성하여 Pod에서 사이드카 컨테이너로 실행하세요.
- 권한 있는(Privileged) 컨테이너는 Fargate에서 지원되지 않습니다.
- Fargate에서 실행되는 포드는 포드 매니페스트에서 HostPort 또는 HostNetwork를 지정할 수 없습니다.
- Fargate 포드의 경우 기본 nofile 및 nproc 소프트 제한은 1,024이고 하드 제한은 6만 5,535입니다.
- GPU는 현재 Fargate에서 사용할 수 없습니다.
- Fargate에서 실행되는 포드는 인터넷 게이트웨이에 대한 직접 경로가 없고 AWS 서비스에 대한 NAT 게이트웨이 액세스 권한이 있는 프라이빗 서브넷에서만 지원되므로 클러스터의 VPC에 프라이빗 서브넷이 있어야 합니다.
- Vertical Pod Autoscaler로 포드 리소스 조정을 사용하여 Fargate 포드의 초기 올바른 CPU 및 메모리 크기를 설정한 다음 Horizontal Pod Autoscaler로 포드 배포 확장을 사용하여 해당 포드의 규모를 조정할 수 있습니다. Vertical Pod Autoscaler가 더 큰 CPU 및 메모리 조합으로 포드를 Fargate에 자동으로 다시 배포하도록 하려면 Vertical Pod Autoscaler의 모드를 Auto 또는 Recreate로 설정하여 올바로 작동하게 해야 합니다.
- VPC에 대해 DNS 확인 및 DNS 호스트 이름을 활성화해야 합니다.
- Amazon EKS Fargate는 가상 머신(VM) 내에서 각 포드를 격리하여 Kubernetes 애플리케이션에 대한 심층 방어 기능을 추가합니다. 이 VM 경계를 통해 컨테이너 이스케이프 시 다른 포드에서 사용하는 호스트 기반 리소스에 대한 액세스를 방지하는데, 이 방법은 컨테이너화된 애플리케이션을 공격하고 컨테이너 외부의 리소스에 대한 액세스 권한을 얻는 일반적인 방법입니다.
- Fargate 프로필은 VPC 보조 CIDR 블록의 서브넷 지정을 지원합니다. 보조 CIDR 블록을 지정할 수도 있습니다. 서브넷에서 사용 가능한 IP 주소의 수는 제한되어 있기 때문입니다. 따라서 클러스터에서 생성할 수 있는 포드의 수가 제한되어 있습니다. 포드에 다른 서브넷을 사용하여 사용 가능한 IP 주소의 수를 늘릴 수 있습니다.
- Amazon EC2 인스턴스 메타데이터 서비스(IMDS)는 Fargate 노드에 배포된 포드에는 사용할 수 없습니다.
- Fargate 포드는 AWS Outposts, AWS Wavelength 또는 AWS 로컬 영역에 배포할 수 없습니다.
- Amazon EKS는 정기적으로 Fargate 포드를 패치하여 보안을 유지해야 합니다.
- Amazon EKS용 Amazon VPC CNI 플러그인은 Fargate 노드에 설치됩니다.
- Fargate에서 실행되는 포드는 수동 드라이버 설치 단계 없이 Amazon EFS 파일 시스템을 자동으로 탑재합니다.
- Amazon EKS는 Fargate 스팟을 지원하지 않습니다.
- Amazon EBS 볼륨을 Fargate 포드에 탑재할 수 없습니다.
- Amazon EBS CSI 컨트롤러는 Fargate 노드에서 실행할 수 있지만 Amazon EBS CSI 노드 DaemonSet은 Amazon EC2 인스턴스에서만 실행할 수 있습니다.
- Kubernetes 작업이 Completed 또는 Failed로 표시된 후에도 작업이 생성하는 포드는 정상적으로 계속 존재합니다. 이 동작을 통해 로그와 결과를 볼 수 있지만 Fargate를 사용하는 경우 나중에 작업을 정리하지 않으면 비용이 발생합니다.
## 2-3. NodeGroup에서 Fargate로 전환 작업
### 2-3-1. 작업 절차
1. EFS용 PV/PVC 생성
2. Application Deployment 재시작 (EC2)
3. System 관련 pod의 Fargate 예외 적용 또는 삭제
```shell
# 항목 조사
- aws-cluster-autoscaler
- aws-efs-csi-driver Helm Chart
- metrics-server Chart

# 삭제 작업
k ns kube-system
helm list -n kube-system
helm get values cluster-autoscaler \
    -n kube-system | tee cluster-autoscaler-values.yaml
helm uninstall cluster-autoscaler
```
4. kube-system namespace 용 Fargate Profile 생성
```shell
aws eks create-fargate-profile \
  --cluster-name Migration-EKS \
  --pod-execution-role-arn arn:aws:iam::XXXXXXXXXXXX:role/Migration-EKS-Pod-Excution-Role \
  --fargate-profile-name ops-kube-system \
  --selectors '[{"namespace": "kube-system"}]' \
  --subnets '["subnet-XXXXXXXXXXX", "subnet-XXXXXXXXXXX"]'
``` 
5. CoreDNS 재시작
```shell
# coredns configmap 백업
kubectl get cm coredns -n kube-system -o yaml| tee coredns-cm.yaml_backup20250218
# deployment 재시작
kubectl rollout restart deployment/coredns -n kube-system
```
6. CoreDNS 재시작 후, CoreDNS 에 등록된 도메인 호출 테스트
```shell
kubectl exec -it nginx-76647f6ddf-82xqk -- sh
nslookup local-domain.com
-> 10.6.180.43
```

7. AWS Load Balancer Controller 재시작
```shell
kubectl rollout restart deployment/aws-load-balancer-controller -n kube-system
```

8. Application용 Fargate Profile 생성
```shell
aws eks create-fargate-profile \
  --cluster-name Migration-EKS \
  --pod-execution-role-arn arn:aws:iam::XXXXXXXXXXXX:role/Migration-EKS-Pod-Excution-Role \
  --fargate-profile-name app-ns-app \
  --selectors '[{"namespace": "app"}]' \
  --subnets '["subnet-XXXXXXXXXXX", "subnet-XXXXXXXXXXX"]'
```
9. EKS Addon 삭제
    - Amazon VPC CNI
    - Amazon EBS CSI Driver
    - Amazon EFS CSI Driver
    - kube-proxy 
## 2-4. 참고 링크
- [AWS Fargate를 사용한 컴퓨팅 관리 간소화](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/fargate.html)
# 3. 사전 조건
# 4. 실습
## 4-2. NodeGroup에서 Fargate로 전환 작업
# 5. 정리
```
sh 99_delete_fargate.sh
```