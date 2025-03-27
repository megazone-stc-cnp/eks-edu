# 1. 목표
- CoreDNS, kube-proxy에 대해서 배우고 실습
- AWS Load Balancer Controller에 대해서 배우고 실습

# 2. 이론
## 2-1. CoreDNS
### 2-1-1. CoreDNS란?
CoreDNS는 Kubernetes 클러스터 DNS로 사용할 수 있는 유연하고 확장 가능한 DNS 서버입니다. 

하나 이상의 노드가 있는 Amazon EKS 클러스터를 시작하면 클러스터에 배포된 노드 수에 관계없이 CoreDNS 이미지의 복제본 2개가 기본적으로 배포됩니다.

CoreDNS 포드는 클러스터의 모든 포드에 대한 이름 확인을 제공합니다.
- Service : service-name.namespace-name.svc.cluster.local
- Pod : pod-ip.namespace-name.pod.cluster.local

## 2-2. kube-proxy
## 2-3. AWS Load Balancer Controller
### 관련 링크
[Amazon EKS 클러스터에서 DNS에 대한 CoreDNS 관리](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/managing-coredns.html)

# 3. 사전 조건
- VPC 설치
- EKS 설치
- Addon 설치
# 4. 실습
## 4-0. 사전 설치
```shell
cd 00_pre_setup
sh 01_install.sh
```

## 4-1. hosts 추가
1. coredns configmap 백업
```shell
cd 01_coredns
sh 01_coredns_configmap_backup.sh
```

2. coredns 내용을 수정하기
```shell
sh 02_coredns_edit_configmap.sh
=============================================
apiVersion: v1
data:
  Corefile: |
    .:53 {
        ....
        reload
        loadbalance

        >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        hosts {                        
            10.43.0.1 myapp.local
            fallthrough
        }
        >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    }
    ....
kind: ConfigMap
=============================================
```
3. coredns deployment 재시작
```shell
sh 03_coredns_restart_deployment.sh
```
4. Pod에서 nslookup 실행
```shell
sh 04_pod_exec.sh
kubectl run test-pod --image=busybox --restart=Never --rm -it -- /bin/sh 
terminal에서 아래와 같이 조회하세요
# nslookup myapp.local

If you don't see a command prompt, try pressing enter.
/ # nslookup myapp.local
Server:		10.100.0.10
Address:	10.100.0.10:53

Name:	myapp.local
Address: 10.43.0.1
```
## 4-2. C Name 등록 ( 설명 )
1. CoreDNS에 특정 도메인을 Internal ALB에 매핑 작업
```shell
sh 02_coredns_edit_configmap.sh
=============================================
apiVersion: v1
data:
  Corefile: |
    .:53 {
        ....
        ready
        rewrite stop {
            name exact working.dot.com internal-alb.ap-northeast-2.elb.amazonaws.com
            answer name internal-alb.ap-northeast-2.elb.amazonaws.com working.dot.com
        }
        kubernetes cluster.local in-addr.arpa ip6.arpa {
          pods insecure
          fallthrough in-addr.arpa ip6.arpa
        }
    }
    ....
kind: ConfigMap
=============================================
```
## 4-3. [AWS LoadBalancer Controller 설치](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/lbc-helm.html)
## 4-3. Ingress 배포
## 4-4. Target Group Binding 배포
# 5. 정리 
```shell
```