# Docker 심화

## 사전 조건
- [0. 교육 환경 구성하기](/00_Setup/README.md) 내용 기반으로 아래의 코드로 생성된 `code-server`에 접속한 상태여야 합니다.
```bash
export IDE_NAME=9641173
export CODE_SERVER_CFN="https://raw.githubusercontent.com/megazone-stc-cnp/eks-edu/refs/heads/main/00_Setup/eks-workshop-vscode-cfn-with-public-subnet.yaml"
aws cloudformation create-stack \
	--stack-name eks-workshop-${IDE_NAME} \
	--template-body "$(curl -fsSL $CODE_SERVER_CFN)" \
	--capabilities CAPABILITY_NAMED_IAM \
	--region ${AWS_REGION}
```

---

## 학습 목표
- 쿠버네티스 클러스터 컴포넌트 구성
- Kubernetes에 App 배포하기
- Ingress 컴포넌트 생성하기
- Persistent Volume 컴포넌트 생성하기
- Helm Chart 사용하기 

---

## 구축 시나리오

### 1. kind가 존재하는지 확인
```
kind get clusters
```

아래와 같이 kind가 존재하지 않아야 한다.

![alt text](<CleanShot 2026-05-04 at 22.57.11.png>)

### 2. kind cluster 생성

#### 2.0 작업 디렉토리로 이동
```
cd ~/environment/eks-edu/02_01_Kubernetes
touch kind-config.yaml
```

#### 2.1 아래의 내용으로 kind-config.yaml를 생성해 준다.
```
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 8000
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
```

#### 2.2 kind cluster 생성 
```
kind create cluster --config kind-config.yaml
```

#### 2.3 생성이 되었는지 확인
```
kubectl cluster-info --context kind-kind
```

아래와 같이 정보가 나오면 정상적으로 생성된 것인다.

![alt text](<CleanShot 2026-05-04 at 23.13.00.png>)

### 3. 외부 서비스를 위해서 ingress-nginx를 배포한다.
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
```

생성이 완료될때 까지 대기를 한다.
```
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s
```

정상적으로 배포가 완료되었는지 확인한다.
```
kubectl -n ingress-nginx get pods
```

아래와 같이 정상적으로 Pod가 올라와 있다.

![alt text](<CleanShot 2026-05-04 at 23.17.55.png>)

## 개발 시나리오

### 1. [1-1 Docker 심화](01_01_docker/README.md) 에서 아래의 요구조건에 맞게 코드를 수정

- postgresql에 DB에 접속해서 counters 테이블에 호출 횟수를 기록한다. ( 첫 로딩시 counters 테이블이 없으면 생성한다.)
- "/" 를 호출할 때 마다, Hello World! <이름> ( count : <호출 횟수> ) 를 출력한다.
- 로그 정보를 /app/logs/YYYYMMDD.log 에 기록한다.

```
cd /home/ec2-user/environment
git clone https://github.com/megazone-stc-cnp/spring-boot-hello-world-sample.git

cd spring-boot-hello-world-sample
```

### 2. 컨테이너 이미지를 ECR에 업로드

시간상 강사가 업로드 한 Public ECR을 사용합니다. ( public.ecr.aws/a8c1n9n2/hcseo/my_spring_boot:v2 )

### 3. 어플리케이션을 배포할 네임스페이스 ( 격리 공간 ) 을 생성한다.

1. samchun namespace를 생성한다.

```
NAMESPACE_NAME=samchun
kubectl create namespace ${NAMESPACE_NAME}
```

2. 생성이 완료되었는지 확인한다.

```
kubectl get namespace
```

### 4. 필요한 데이터 베이스 생성

#### 4.1 Postgresql DB 설치를 작업

1. 컨테이너 이미지 검색을 위해서 DockerHub에서 찾듯이 Kubernetes에 설치 패키지를 [ArtifactHub](https://artifacthub.io) 에서 찾는다.
  [ArtifactHub](https://artifacthub.io) 에서 ``postgresql`` 를 검색한다.

2. postgresql repo를 등록한다.
```
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

3. 아래의 명령으로 postgresql app 이름을 찾는다.
```
helm search repo bitnami

-> bitnami/postgresql
```

4. postgresql은 보안상 패스워드를 보안상 평문으로 저장하지 않기 위해 secret 컴포넌트로 저장한다.

```
SECRET_NAME=postgresql-secret
ADMIN_PASSWORD=adminpwd
USER_PASSWORD=springpwd

echo $SECRET_NAME
echo $ADMIN_PASSWORD
echo $USER_PASSWORD
echo $NAMESPACE_NAME

kubectl create secret generic ${SECRET_NAME} \
  --from-literal=postgres-password="${ADMIN_PASSWORD}" \
  --from-literal=password="springpwd" \
  -n $NAMESPACE_NAME
```

4. 설정값을 세팅하게 value.yaml 파일을 아래 내용으로 작성한다.

```
touch value.yaml

# 아래 내용을 작성
# values.yaml - Bitnami PostgreSQL Helm Chart

auth:
  # 생성할 커스텀 유저명
  username: "springuser"
  # 생성할 데이터베이스명 (username이 owner가 됨)
  database: "springdb"

  # 평문 비밀번호 대신 Secret 참조
  existingSecret: "postgresql-secret"
  secretKeys:
    adminPasswordKey: "postgres-password"   # postgres 슈퍼유저
    userPasswordKey: "password"             # springuser
```

4. postgresql을 helm 명령을 이용해서 생성한다.
```
RELEASE_NAME=my-postgresql
CHART_VERSION=18.6.2

echo $NAMESPACE_NAME
echo $RELEASE_NAME
echo $CHART_VERSION

helm install ${RELEASE_NAME} \
  bitnami/postgresql \
  -n $NAMESPACE_NAME \
  --version ${CHART_VERSION}
```

5. 설치가 잘 되었는지 확인
```
echo $NAMESPACE_NAME

helm -n samchun list
```

아래와 같이 상태가 deployed 가 나와야 한다.

![alt text](<CleanShot 2026-05-05 at 23.08.22.png>)

6. 데이터베이스가 잘 생성되었는지 확인

```
kubectl get pods -n samchun

-> my-postgresql-0

kubectl exec -it my-postgresql-0 -n samchun -- \
  psql -U springuser -d springdb
```

## 참고 URL
- [Kubectl 명령어 Cheat](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands)