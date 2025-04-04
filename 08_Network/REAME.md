# 1. 목표
- VPC CNI에 대해서
# 2. 이론
## 2-1. VPC CNI란 ?
## 2-2. 맞춤형 네트워킹
1. 기본적으로 Kubernetes용 Amazon VPC CNI 플러그인이 Amazon EC2 노드에 대한 보조 탄력적 네트워크 인터페이스 (네트워크 인터페이스)를 생성할 때 노드의 기본 네트워크 인터페이스와 동일한 서브넷에 이를 생성합니다
2. 또한 기본 네트워크 인터페이스에 연결된 동일한 보안 그룹을 보조 네트워크 인터페이스에 연결합니다. 
3. 다음 중 하나 이상의 이유로 플러그 인이 다른 서브넷에서 보조 네트워크 인터페이스를 생성하거나 다른 보안 그룹을 보조 네트워크 인터페이스에 연결하거나, 둘 다 하려고 할 수 있습니다.
    - 기본 네트워크 인터페이스가 있는 서브넷에서 사용할 수 있는 IPv4 주소의 수는 제한되어 있습니다. 이렇게 하면 서브넷에서 생성할 수 있는 포드 수가 제한될 수 있습니다. 보조 네트워크 인터페이스에 다른 서브넷을 사용하면 포드에 사용 가능한 IPv4 주소 수를 늘릴 수 있습니다.
    - 보안상의 이유로 포드는 노드의 기본 네트워크 인터페이스와 다른 서브넷 또는 보안 그룹을 사용해야 할 수 있습니다.
    - 노드는 퍼블릭 서브넷에서 구성되며, 포드를 프라이빗 서브넷에 배치할 수 있습니다. 퍼블릭 서브넷과 연결된 라우팅 테이블에는 인터넷 게이트웨이로 가는 경로가 포함됩니다. 프라이빗 서브넷과 연결된 라우팅 테이블에는 인터넷 게이트웨이로 가는 경로가 포함되지 않습니다.
### 2-3. 고려 사항
- 사용자 지정 네트워킹을 사용 설정하면 기본 네트워크 인터페이스에 할당된 IP 주소가 포드에 할당되지 않습니다. 보조 네트워크 인터페이스의 IP 주소만 포드에 할당됩니다.
- 클러스터에서 **IPv6 패밀리를 사용하는 경우 사용자 지정 네트워킹을 사용할 수 없습니다.**
- 사용자 지정 네트워킹을 사용하여 IPv4 주소 소모를 완화하려는 경우 대신 IPv6 패밀리를 사용하여 클러스터를 생성할 수 있습니다.
- 보조 네트워크 인터페이스에 지정된 서브넷에 배포된 포드는 노드의 기본 네트워크 인터페이스와 다른 서브넷 및 보안 그룹을 사용할 수 있다고 해도 **서브넷과 보안 그룹은 노드와 동일한 VPC에 있어야 합니다.**
- **Fargate의 경우 서브넷은 Fargate 프로필을 통해 제어**됩니다.
## 2-4. IP 주소 늘리기
# 3. 사전 조건
# 4. 실습
## 4.1 VPC에 Secondary Cidr에 추가하기
```
sh 01_get_output.sh
```
# 5. 정리