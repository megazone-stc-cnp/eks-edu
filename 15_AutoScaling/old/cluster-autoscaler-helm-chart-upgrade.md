# cluster autoscaler Helm Chart 업그레이드

## 1. IRSA 연동 Role 확인
```shell
kubectl get sa -A -o yaml | grep eks.amazonaws.com/role-arn | grep -e 'autoscal'
```

## 2. Role에 연동된 Policy 와 최신 cluster autoscaler 가 필요로한 Policy 확인
1. AWS Management Console > IAM > Role > 1번에서 조회된 IRSA의 Role 선택
2. 최신 권장 Policy : https://docs.aws.amazon.com/ko_kr/eks/latest/best-practices/cas.html

## 3. cluster autoscaler 와 EKS 버전 호환 버전 확인
1. [Release 페이지에서 확인](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/README.md#releases)

   ![img.png](image/cluster-autoscaler-release-support-version.png)

## 4. Helm Chart 버전 확인

1. [Artifact Hub 페이지에서 업그레이드 Image/Helm Chart 버전 확인](https://artifacthub.io/packages/helm/cluster-autoscaler/cluster-autoscaler)

   ![img.png](image/cluster-autoscaler-helm-chart-version.png)

##  5. 최신 Image를 ECR에 업로드

1. 04장 참조

## 6. Helm Upgrade

### 6.1 기존 Helm Value Backup
```
helm get values cluster-autoscaler \
    -n kube-system | tee cluster-autoscaler-values.yaml
```
### 6.2 cluster-autoscaler-values.yaml 에서 repository 경로 및 tag에 최신 Image 정보로 변경
```
예)
repository: ...
tag: v1.31.0
```

### 6.3 현재 Helm History 확인

```shell
helm history cluster-autoscaler -n kube-system

# 롤백이 필요로한 경우 현재 구동된 버전이 필요로 하므로 기록함
```

### 6.4 Helm Upgrade

```
HELM_VERSION=<4번에서 설치하고자 하는 Helm Version을 기록>

helm upgrade cluster-autoscaler \
	cluster-autoscaler/cluster-autoscaler \
	-n kube-system \
	-f cluster-autoscaler-values.yaml \
	--version ${HELM_VERSION} 
```

## 7 Rollback이 필요로한 경우
```shell
helm rollback cluster-autoscaler <6.3에서 기록한 이전 버전> -n kube-system
```