# Kubernetes 실습

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

![alt text](<images/CleanShot 2026-05-04 at 22.57.11.png>)

### 2. kind cluster 생성

#### 2.0 작업 디렉토리로 이동
```
cd ~/environment/eks-edu/02_01_Kubernetes
```

#### 2.1 아래의 내용으로 kind-config.yaml를 생성해 준다.
```
cat >kind-config.yaml<<EOF
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
EOF
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

![alt text](<images/CleanShot 2026-05-04 at 23.13.00.png>)

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

![alt text](<images/CleanShot 2026-05-04 at 23.17.55.png>)

## 개발 시나리오

### 1. [1-1 Docker 심화](01_01_docker/README.md) 에서 아래의 요구조건에 맞게 코드를 수정

- postgresql에 DB에 접속해서 counters 테이블에 호출 횟수를 기록한다. ( 첫 로딩시 counters 테이블이 없으면 생성한다.)
- "/" 를 호출할 때 마다, Hello World! <이름> ( count : <호출 횟수> ) 를 출력한다.
- 로그 정보를 /app/logs/application.log 에 기록한다. 그 다음날에 app/logs/YYYYMMDD.log 로 복사해서 저장한다.

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

echo $NAMESPACE_NAME

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
cd ~/environment/eks-edu/02_01_Kubernetes
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

3. 아래의 명령으로 postgresql app 이름을 찾는다.
```
helm search repo bitnami

-> bitnami/postgresql
-> CHART VERSION : 18.6.2
```

4. 수정해야 할 values.yaml 을 다운로드 받는다.
```
helm show values bitnami/postgresql --version 18.6.2 > origin_values.yaml
```

5. postgresql은 보안상 패스워드를 보안상 평문으로 저장하지 않기 위해 secret 컴포넌트로 저장한다.

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
  --from-literal=password="${USER_PASSWORD}" \
  -n $NAMESPACE_NAME

# 확인하기
kubectl -n samchun get secret postgresql-secret -oyaml
```

6. 저장된 data 부분을 Base64로 인코딩되어 있으므로, [Base64 사이트](https://www.base64decode.org/ko/) 에서 암호를 풀어본다.

7. 설정값을 세팅하게 value.yaml 파일을 아래 내용으로 작성한다.

```
cd ~/environment/eks-edu/02_01_Kubernetes

# 아래 내용을 작성
# values.yaml - Bitnami PostgreSQL Helm Chart

cat >value.yaml<<EOF
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

primary:
  persistence:
    enabled: true
    size: 1Gi
EOF
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
  -f value.yaml \
  --version ${CHART_VERSION}
```

5. 설치가 잘 되었는지 확인
```
echo $NAMESPACE_NAME

helm -n samchun list
```

아래와 같이 상태가 deployed 가 나와야 한다.

![alt text](<images/CleanShot 2026-05-05 at 23.08.22.png>)

6. 설치된 전체 목록을 확인한다.
```
echo ${NAMESPACE_NAME} 
kubectl -n ${NAMESPACE_NAME} get all
```

7. 데이터베이스가 잘 생성되었는지 확인

```
kubectl get pods -n samchun

-> my-postgresql-0

kubectl exec -it my-postgresql-0 -n samchun -- \
  env PGPASSWORD=springpwd psql -U springuser -d springdb
```

7. temp 테이블 생성하기
```
CREATE TABLE temp (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    description TEXT,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

8. 테이블 생성 확인
```
\dt
```

#### 4.2 kubectl 명령을 좀더 세련되게
1. [krew 설치](https://krew.sigs.k8s.io/docs/user-guide/setup/install/)
```
(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)
```
2. export 해주기
```
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
```
3. [Kubectl plugins available](https://krew.sigs.k8s.io/plugins/) 에서 아래 항목 추가
```
kubectl krew install ctx ns df-pv neat get-all

# 상세 설명
ctx : 여러 Kubernetes를 전환할 때 사용
ns : default Namespace를 전환할 때 사용
df-pv : Persistent Volume 조회 때 사용
neat : yaml 내용을 출력시 불필요한 부분 제거
get-all : 모든 항목 보이게
```

4. 아래 명령으로 default Namespace를 samchun 으로 변경
```
kubectl ns samchun
```

#### 4.3 pod를 재기동하기

1. pod를 삭제하기
```
kubectl get pods

kubectl delete pod my-postgresql-0
```

2. 테이블이 존재하는지 확인
```
kubectl get pods -n samchun

-> my-postgresql-0

kubectl exec -it my-postgresql-0 -n samchun -- \
  env PGPASSWORD=springpwd psql -U springuser -d springdb

springdb=> \dt
```

3. 데이터 저장하는 Persistent Volume이 존재하는지 확인
```
kubectl get pods -oyaml

# 아래 내용이 존재하는지 확인
volumes:
    - name: data
      persistentVolumeClaim:
        claimName: data-my-postgresql-0
```

### 5. Application 배포
#### 5.1 deployment 생성
1. deployment 생성
```
DEPLOYMENT_NAME=my-springboot
IMAGE_NAME=public.ecr.aws/a8c1n9n2/hcseo/my_spring_boot:v2
PORT_NAME=8080

echo $DEPLOYMENT_NAME
echo $IMAGE_NAME
echo $NAMESPACE_NAME
echo $PORT_NAME

kubectl -n $NAMESPACE_NAME create deployment ${DEPLOYMENT_NAME} --image=${IMAGE_NAME} --port=$PORT_NAME
```

2. deployment 생성이 잘되었는지 확인
```
kubectl -n $NAMESPACE_NAME get deploy
```

3. 제대로 안떠 있는 부분을 확인

![alt text](<images/CleanShot 2026-05-06 at 01.03.14.png>)

4. 로그 확인

```
kubectl -n $NAMESPACE_NAME get pods

-> NAME: my-springboot-677c6dbd6c-shqcj
POD_NAME=
kubectl -n $NAMESPACE_NAME logs ${POD_NAME}
```

#### 5.2 deploy를 띄울 때 Database 연동하게 config 작업

1. 배포된 deployment 정보를 yaml로 저장하기
```
DEPLOYMENT_NAME=my-springboot

echo $DEPLOYMENT_NAME
echo $NAMESPACE_NAME

kubectl -n $NAMESPACE_NAME get deployment ${DEPLOYMENT_NAME} -oyaml | tee temp_deployment.yaml
```

2. Database에 접속할 도메인 정보를 찾는다.
```
kubectl -n samchun get service

-> NAME: my-postgresql
```

3. Application에 접속할 데이터 베이스 정보를 뽑는다.
```
SPRING_DATASOURCE_URL=jdbc:postgresql://my-postgresql:5432/springdb
SPRING_DATASOURCE_USERNAME=springuser
SPRING_DATASOURCE_PASSWORD=springpwd
```

4. deployment에 환경 변수를 주입하기 위해 secret를 생성한다.
```
# 아래 내용을 등록한다.
cat >springboot-secret.yaml<<EOF
apiVersion: v1
kind: Secret
metadata:
  name: spring-boot-secret
type: Opaque
stringData:
  datasource-url: jdbc:postgresql://my-postgresql:5432/springdb
  datasource-username: springuser
  datasource-password: springpwd
EOF
```

5. 아래와 같이 secret를 생성한다.
```
kubectl -n samchun apply -f springboot-secret.yaml
```

6. 생성이 잘 되었는지 확인한다.
```
kubectl -n samchun get secret
```

7. temp_deployment.yaml 에 아래와 같이 변경한다.
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-springboot
  namespace: samchun
spec:
  replicas: 1
  selector:
    matchLabels:
      app: my-springboot
  template:
    metadata:
      labels:
        app: my-springboot
    spec:
      containers:
      - image: public.ecr.aws/a8c1n9n2/hcseo/my_spring_boot:v2
        imagePullPolicy: IfNotPresent
        name: my-spring-boot-4psh4
        ports:
        - containerPort: 8080
          protocol: TCP
        env:
          - name: SPRING_DATASOURCE_URL
            valueFrom:
              secretKeyRef:
                name: spring-boot-secret
                key: datasource-url
          - name: SPRING_DATASOURCE_USERNAME
            valueFrom:
              secretKeyRef:
                name: spring-boot-secret
                key: datasource-username
          - name: SPRING_DATASOURCE_PASSWORD
            valueFrom:
              secretKeyRef:
                name: spring-boot-secret
                key: datasource-password
```

8. deployment 재기동
```
kubectl -n samchun get deploy

kubectl -n samchun delete deploy/my-springboot

kubectl -n samchun apply -f temp_deployment.yaml
``` 

9. pod가 잘 떴는지 확인
```
kubectl -n samchun get pods
```

10. 아래와 같이 정상적으로 떴는지 확인

![alt text](<images/CleanShot 2026-05-06 at 01.36.04.png>)

#### 5.3 외부에서 서비스를 유입 받게 서비스 생성
1. 서비스 생성
```
DEPLOYMENT_NAME=my-springboot
NAMESPACE_NAME=samchun
PORT_NAME=8080
SERVICE_NAME=my-springboot-service

echo $DEPLOYMENT_NAME
echo $NAMESPACE_NAME
echo $PORT_NAME
echo $SERVICE_NAME

kubectl -n ${NAMESPACE_NAME} expose deployment $DEPLOYMENT_NAME --name=$SERVICE_NAME --port=$PORT_NAME --target-port=$PORT_NAME
```

2. 서비스가 제대로 생성되었는지 확인
```
kubectl -n ${NAMESPACE_NAME} get service

kubectl -n ${NAMESPACE_NAME} get endpoints
```

#### 5.4 Ingress 생성
1. springboot-ingress.yaml 로 배포
```
cat > springboot-ingress.yaml<<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-springboot-ingress
  namespace: samchun  
spec:
  ingressClassName: nginx
  rules:
    - http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: my-springboot-service
                port:
                  number: 8080
EOF

kubectl apply -f springboot-ingress.yaml
```

#### 5.5 서비스 확인
```
http://<Public IP>:8000/
```

아래와 같이 컨텐츠가 정상적으로 나와야 한다.

![alt text](<images/CleanShot 2026-05-06 at 18.20.43.png>)

#### 5.6 /app/logs 디렉토리를 유지하기 위해서, Persistent Volume을 연동
1. 기존 Storageclass 이름 확인하기
```
kubectl get storageclass

-> NAME: standard
```

2. PVC를 생성
```
PVC_NAME=my-springboot-pvc

echo ${PVC_NAME}

cat >my_springboot_pvc.yaml<<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-springboot-pvc
  namespace: samchun
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: standard # Maps to local-path in KinD
  resources:
    requests:
      storage: 1Gi
EOF

kubectl apply -f my_springboot_pvc.yaml
```

3. PVC 생성이 잘되었는지 확인
```
kubectl -n samchun get pvc
```

4. 아직 Pod에서 사용하지 않기 때문에 Volume이 생성되지 않았다.

![alt text](<images/CleanShot 2026-05-06 at 21.07.38.png>)

5. temp_deployment.yaml에 내용 추가
```
apiVersion: apps/v1
kind: Deployment
metadata:
  annotations:
    deployment.kubernetes.io/revision: "1"
  labels:
    app: my-springboot
  name: my-springboot
  namespace: samchun
spec:
  progressDeadlineSeconds: 600
  replicas: 1
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      app: my-springboot
  template:
    metadata:
      labels:
        app: my-springboot
    spec:
      containers:
      - image: public.ecr.aws/a8c1n9n2/hcseo/my_spring_boot:v2
        imagePullPolicy: Always
        name: my-spring-boot-2wvkg
        ports:
        - containerPort: 8080
          protocol: TCP
        env:
          - name: SPRING_DATASOURCE_URL
            valueFrom:
              secretKeyRef:
                name: spring-boot-secret
                key: datasource-url
          - name: SPRING_DATASOURCE_USERNAME
            valueFrom:
              secretKeyRef:
                name: spring-boot-secret
                key: datasource-username
          - name: SPRING_DATASOURCE_PASSWORD
            valueFrom:
              secretKeyRef:
                name: spring-boot-secret
                key: datasource-password
        volumeMounts:
        - name: logs-volume
          mountPath: /app/logs
      volumes:
      - name: logs-volume
        persistentVolumeClaim:
          claimName: my-springboot-pvc
```

6. deploy를 다시 시작한다.
```
kubectl apply -f temp_deployment.yaml
```

9. deploy를 삭제하고 다시 띄어본다.
```
# deployment를 삭제한다.
kubectl -n samchun delete deploy my-springboot

# 삭제된것 확인
kubectl -n samchun get deploy

# 다시 배포
kubectl apply -f temp_deployment.yaml
```

10. container안에 들어가서 /app/logs 디렉토리 내용이 유지되는지 확인
```
k exec -it my-springboot-ddcfddc97-rlf8r -- sh

ls /app/logs
```

---

## 실습 환경 삭제하기

생성된 자원을 삭제하려면 CloudShell 에서 아래 명령어를 입력해 주세요.

```bash
export IDE_NAME=9641173

aws cloudformation delete-stack --stack-name eks-workshop-${IDE_NAME}
```

CloudShell이 아닌 CloudFormation에서 직접 Stack 을 선택하여 삭제하셔도 됩니다.

---

## 참고 URL
- [Kubectl 명령어 Cheat](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands)
- [파드](https://kubernetes.io/ko/docs/concepts/workloads/pods/)
- [서비스](https://kubernetes.io/ko/docs/concepts/services-networking/service/)
- [인그레스](https://kubernetes.io/ko/docs/concepts/services-networking/ingress/)
- [deployment](https://kubernetes.io/ko/docs/concepts/workloads/controllers/deployment/)
- [Krew install](https://krew.sigs.k8s.io/docs/user-guide/setup/install/)
- [Krew plugins available](https://krew.sigs.k8s.io/plugins/)