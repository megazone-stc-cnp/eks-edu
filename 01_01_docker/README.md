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
- AWS ECR에 이미지 업로드 하기
- Docker 명령어 
- Dockerfile 심화
    - Multi-stage Build를 이용한 이미지 최적화 방법 학습
    - 효율적인 Docker 이미지 빌드 전략 이해
- Docker Compose
    - Docker Compose의 개념과 필요성 이해
    - docker-compose.yml 작성 방법 학습
    - 다중 컨테이너 애플리케이션 구성 및 실행 실습

---

## 개발 시나리오
### 1. Java Application 개발

#### 1.1 나의 이름을 출력하는 Java 코드 개발을 진행한다.

```
cd /home/ec2-user/environment
git clone https://github.com/megazone-stc-cnp/spring-boot-hello-world-sample.git

cd spring-boot-hello-world-sample
```

#### 1.2 나의 이름을 my_name.txt에 변경한다.

![alt text](<images/CleanShot 2026-04-29 at 17.50.05@2x.png>)

#### 1.3 Application을 구동한다.
```
mvn spring-boot:run
```

아래와 같이 Browser에서 http://[스택에 IdePublicIp]:8080 접속해 본다.

![alt text](<images/CleanShot 2026-04-29 at 17.59.34@2x.png>)

### 2. Docker로 마이그레이션

#### 2.1 Docker 실행시 필요한 항목들 정리
```
pom.xml 파일 필요
src/ 필요
my_name.txt 파일 필요
라이브러리 다운로드 : mvn dependency:go-offline -q
패키징 명령어 : mvn package -DskipTests -q
실행 명령어 : java -jar target/hello-0.0.1-SNAPSHOT.jar
```

#### 2.2 java를 구동할 수 있는 Docker base Image를 찾기

[Docker Hub 사이트](https://hub.docker.com/) 에서 java Image 검색 ( maven 빌드, java 포함 )
- 나의 Pick : maven:3.9-eclipse-temurin-17

#### 2.3 Docker file 작성

Dockerfile 에 아래의 내용을 추가
```
cd ~/environment/spring-boot-hello-world-sample
touch Dockerfile

- 아래 내용 입력
FROM maven:3.9-eclipse-temurin-17

WORKDIR /app

COPY pom.xml .
RUN mvn dependency:go-offline -q

COPY src ./src
COPY my_name.txt .
RUN mvn package -DskipTests -q

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "target/*.jar"]
```

#### 2.4 Docker image 생성

아래 명령으로 기존 docker image 여부 확인

```
docker images
```

아래 명령으로 docker image 생성
```
docker build -t my_spring_boot .
```

생성이 되었는지 아래의 명령으로 확인
```
docker images
```

용량 사이즈 확인

![alt text](<images/CleanShot 2026-04-29 at 18.57.52@2x.png>)

### 3. Docker 파일 사이즈 최적화

#### 3.1 Multi-stage Build 적용
```
- Dockerfile을 아래와 같이 수정
# ---- 빌드 스테이지 ----
FROM maven:3.9-eclipse-temurin-17 AS builder
WORKDIR /app

# 의존성 캐시 레이어 (pom.xml만 먼저 복사)
COPY pom.xml .
RUN mvn dependency:go-offline -q

# 소스 복사 후 빌드
COPY src ./src
COPY my_name.txt .
RUN mvn package -DskipTests -q

# ---- 실행 스테이지 ----
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

#### 3.2 Docker Image 생성
1. 아래 명령으로 기존 docker image 여부 확인

```
docker images
```

2. 아래 명령으로 docker image 생성
```
docker build -t my_spring_boot:multi-stage .
```

3. 생성이 되었는지 아래의 명령으로 확인
```
docker images
```

4. 용량 사이즈 확인

![alt text](<images/CleanShot 2026-04-29 at 19.04.27@2x.png>)

### 4. Docker Image를 올리기 위한 ECR 생성

1. AWS Management Console에서 ```ecr``` 입력하여 Elastic Container Registry 로 이동

![alt text](<images/CleanShot 2026-04-29 at 19.06.52@2x.png>)

2. 리포지토리 메뉴에서 리포지토리 생성 버튼 클릭

![alt text](<images/CleanShot 2026-04-29 at 19.07.53@2x.png>)

3. 아래 정보를 입력하고, 생성 버튼 클릭

- 리포지토리 이름 : my_spring_boot

4. 아래와 같이 프라이빗 리포지토리 생성 확인 하고 URI 복사 ( 예: 539666729110.dkr.ecr.ap-northeast-2.amazonaws.com/my_spring_boot )

![alt text](<images/CleanShot 2026-04-29 at 19.10.38@2x.png>)

### 5. 로컬 Docker Image 를 생성한 AWS ECR에 업로드

1. Private ECR 로그인
```
source ~/environment/eks-edu/env.sh
aws ecr get-login-password  | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
```

그러면 아래와 같이 Login Succeeded 메시지가 나와야 한다.

![alt text](<images/CleanShot 2026-04-29 at 19.19.11@2x.png>)

2. Private ECR Repository 경로로 Tagging
```
docker tag my_spring_boot:multi-stage ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/my_spring_boot:multi-stage
```

3. Private ECR Repository 경로로 Tagging 되었는지 확인
```
docker images
```

4. docker image를 Private ECR Repository 로 업로드
```
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/my_spring_boot:multi-stage
```

5. AWS Management Console에서 이미지 업로드 여부 확인 ( 검색: ecr > 리포지토리 > 검색: my_spring_boot > my_spring_boot 선택 )

![alt text](<images/CleanShot 2026-04-29 at 19.23.52@2x.png>)

6. Local에 있는 이미지 삭제

```
docker image prune -a
```

7. docker image 확인

```
docker images
```

### 6. Private ECR로 컨테이너 실행

1. 아래의 명령으로 실행
```
docker run -p 8080:8080 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/my_spring_boot:multi-stage
```

2. WebBrowser에서 접근 시 Unknown으로 나옴

![alt text](<images/CleanShot 2026-04-29 at 19.36.29@2x.png>)

3. Container 를 백그라운드로 실행

```
docker run -d -p 8080:8080 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/my_spring_boot:multi-stage
```

4. docker exec 명령으로 터미널 접속
```
docker ps
-> 컨테이너 ID 확인

docker exec -it <컨테이너명> /bin/bash
# docker exec -it 701e90a50cfe sh
```

### 7. Dockerfile 재작성

1. Dockerfile에서 my_name.txt 파일을 추가하게 변경
```
FROM maven:3.9-eclipse-temurin-17 AS builder
WORKDIR /app

# 의존성 캐시 레이어 (pom.xml만 먼저 복사)
COPY pom.xml .
RUN mvn dependency:go-offline -q

# 소스 복사 후 빌드
COPY src ./src
RUN mvn package -DskipTests -q

# ---- 실행 스테이지 ----
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar
COPY my_name.txt .
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

2. 다시 빌드해서 업로드 작업
```
docker build -t my_spring_boot:v2 .
docker tag my_spring_boot:v2 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/my_spring_boot:v2
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/my_spring_boot:v2
docker run -d -p 8080:8080 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/my_spring_boot:v2
```

3. 기존 실행되는 컨테이너 삭제후 재실행
```
docker ps
-> 컨테이너 확인
CONTAINER_ID=701e90a50cfe
docker stop ${CONTAINER_ID}
docker rm ${CONTAINER_ID}

docker run -d --name my_spring_boot -p 8080:8080 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/my_spring_boot:v2
```

### 8. mysql 연동

#### 8.1 docker run 명령을 docker-compose.yaml 로 변경

1. docker run 명령어에서 필요한 항목들을 추출
```
--name my_spring_boot
-p 8080:8080 -> 노출 포트
image : ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/my_spring_boot
tag : v2
```

2. 이 정보 기반으로 docker-compose.yaml 생성
```
services:
  my_spring_boot:
    container_name: my_spring_boot   # --name 에 해당
    image: ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/my_spring_boot:v2
    ports:
      - "8080:8080"
```

3. .env 에 아래 내용 생성
```
AWS_ACCOUNT_ID=539666729110
AWS_REGION=ap-northeast-2
```

4. 아래 명령으로 container 실행
```
docker compose up
```

5. 웹 브라우저에서 실행

6. 백그라운드로 실행
```
docker compose up -d
```

7. 컨테이너 실행 여부 확인
```
docker compose ps
```

8. 로그 확인
```
docker compose logs
```

#### 8.2 mysql 부분 추가

1. docker hub에서 mysql 검색

2. docker-compose.yaml에 mysql 부분 추가
```
services:
  ...
  db:
    image: mysql:8.0
    container_name: my-mysql
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: composedb
      MYSQL_USER: appuser
      MYSQL_PASSWORD: apppassword    
    restart: always
```

3. docker-compose를 재실행
```
# 컨테이너 중지 + 삭제
docker compose down
# 컨테이너 시작
docker compose up -d
```

4. mysql 동작 확인
```
docker compose ps
docker compose logs db
```

#### 9. 연동

1. my_spring_boot 앱과 db를 연결 작업
```
services:
  my_spring_boot:
    container_name: my_spring_boot
    image: ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/my_spring_boot:v2
    ports:
      - "8080:8080"
    environment:
      SPRING_DATASOURCE_URL: jdbc:mysql://db:3306/composedb?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
      SPRING_DATASOURCE_USERNAME: appuser
      SPRING_DATASOURCE_PASSWORD: apppassword
    depends_on:
      db:
        condition: service_healthy  # db 헬스체크 통과 후 스프링 시작
    restart: unless-stopped
    networks:
      - spring-mysql-net

  db:
    image: mysql:8.0
    container_name: my-mysql
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: composedb
      MYSQL_USER: appuser
      MYSQL_PASSWORD: apppassword
    volumes:
      - mysql_data:/var/lib/mysql   # 데이터 영속성
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-u", "root", "-prootpassword"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
    restart: always
    networks:
      - spring-mysql-net

volumes:
  mysql_data:

networks:
  spring-mysql-net:
    driver: bridge
```

- LINE 8-10 : DB 접속을 위한 환경변수 설정
- LINE 12 : Application이 실행 전에 DB가 먼저 실행되고 Health check가 통과 되어야 한다.
- LINE 14 : restart 옵션중 하나이며, stop한 경우는 제외
- LINE 16 : 네트워크 구성 ( 설정을 하지 않아도 네트워크 구성됨 )
- LINE 27 : mysql은 데이터 베이스에 데이터가 쌓여야 하며, docker가 재시작 되어도 유지가 되어야 하므려, Volume으로 별도 구성
- LINE 28 : Health Check

2. 재기동
```
docker compose down

docker compose up -d
```
## 1. Docker 명령어

Docker의 주요 명령어와 리소스 간의 관계는 다음과 같습니다.

```
  ┌───────────────────────┐
  │  Docker Hub / Registry│
  │     (원격 저장소)        │
  └───────┬───────▲───────┘
          │       │
   docker pull  docker push
          │       │
          ▼       │
  ┌───────────────────────┐         ┌───────────────────────┐
  │    Local Images       │◀─────── │   Build Context       │
  │    (로컬 이미지)         │ docker  │  (소스코드/Dockerfile)  │
  │                       │  build  │                       │
  └──┬────────▲───────┬───┘         └───────────────────────┘
     │        │       │
  docker run  │    docker rmi             ┌──────────────────┐
     │        │    (이미지 삭제)             │   Tar / File     │
     │   docker commit          save ────▶│   (이미지 파일)     │
     ▼        │                 load ◀────│                  │
  ┌───────────────────────┐               └──────────────────┘
  │  Running Container    │
  │  (실행 중인 컨테이너)      │──── docker exec (컨테이너 내 명령 실행)
  │                       │──── docker logs (컨테이너 로그 확인)
  └───────┬───────▲───────┘
          │       │
  docker stop   docker start
          │       │
          ▼       │
  ┌───────────────────────┐
  │  Stopped Container    │──── docker rm (컨테이너 삭제)
  │  (정지된 컨테이너)        │
  └───────────────────────┘
```

---

| 분류 | 명령어 | 설명 |
| --- | --- | --- |
| 이미지 | `docker pull <이미지명>` | Registry에서 이미지 다운로드 |
| | `docker build -t <이미지명> .` | Dockerfile로 이미지 빌드 |
| | `docker push <이미지명>` | Registry에 이미지 업로드 |
| | `docker images` | 로컬 이미지 목록 확인 |
| | `docker rmi <이미지명>` | 이미지 삭제 |
| | `docker save -o <파일명>.tar <이미지명>` | 이미지를 tar 파일로 저장 |
| | `docker load -i <파일명>.tar` | tar 파일에서 이미지 로드 |
| 컨테이너 | `docker run <이미지명>` | 이미지로 컨테이너 생성 및 실행 |
| | `docker stop <컨테이너>` | 실행 중인 컨테이너 정지 |
| | `docker start <컨테이너>` | 정지된 컨테이너 재시작 |
| | `docker rm <컨테이너>` | 컨테이너 삭제 |
| | `docker exec -it <컨테이너> sh` | 실행 중인 컨테이너에서 명령 실행 |
| | `docker logs <컨테이너>` | 컨테이너 로그 확인 |
| | `docker commit <컨테이너>` | 컨테이너를 이미지로 저장 |


## 2. Dockerfile 심화

### 2-1. Docker 이미지 레이어 구조

Docker 이미지는 여러 개의 읽기 전용 레이어(Layer)로 구성됩니다.
Dockerfile의 각 지시문(`FROM`, `RUN`, `COPY` 등)은 하나의 레이어를 생성하며, 이 레이어들이 순서대로 쌓여 최종 이미지를 구성합니다.

```
┌─────────────────────────┐
│   Container Layer (R/W) │  ← 컨테이너 실행 시 생성 (쓰기 가능)
├─────────────────────────┤
│   Layer 4: CMD          │  ← Dockerfile 지시문마다
│   Layer 3: RUN          │     레이어가 생성됨 (읽기 전용)
│   Layer 2: COPY         │
│   Layer 1: FROM         │
└─────────────────────────┘
```

---

이 레이어 구조가 중요한 이유는 다음과 같습니다.

| 특성 | 설명 |
| --- | --- |
| 캐싱 | 변경되지 않은 레이어는 재사용되어 빌드 속도가 빨라짐 |
| 공유 | 동일한 베이스 이미지를 사용하는 여러 이미지가 레이어를 공유하여 디스크 절약 |
| 이미지 크기 | 불필요한 레이어가 많으면 이미지 크기가 커짐 |

따라서 효율적인 Dockerfile 작성은 곧 **이미지 크기 최적화**와 **빌드 속도 향상**으로 이어집니다.

---

### 2-2. Multi-stage Build란?

Multi-stage Build는 하나의 Dockerfile 안에서 **여러 개의 `FROM` 지시문**을 사용하여 빌드 단계를 분리하는 기법입니다.

이 기법이 필요한 이유를 예시로 살펴보겠습니다.

---

#### 일반적인 빌드의 문제점

Java, Go, TypeScript 등의 언어로 작성된 애플리케이션은 빌드 과정에서 컴파일러, 빌드 도구, 의존성 라이브러리 등이 필요합니다.
하지만 실제 실행 시에는 이러한 빌드 도구가 필요하지 않습니다.

#### Multi-stage Build의 효과

| 항목 | 일반 빌드 | Multi-stage Build |
| --- | --- | --- |
| 이미지 크기 | ~800MB (Go 컴파일러 포함) | ~15MB (Alpine + 바이너리) |
| 보안 | 빌드 도구, 소스 코드 노출 | 실행에 필요한 파일만 포함 |
| 빌드 속도 | 단일 단계 | 레이어 캐싱 활용 가능 |

---

#### 빌드 효율을 높이는 팁

1. **변경이 적은 파일을 먼저 COPY**: `package.json`을 먼저 복사하고 `yarn install`을 실행하면, 소스 코드만 변경되었을 때 의존성 설치 레이어가 캐싱됩니다.

2. **`.dockerignore` 활용**: 불필요한 파일(node_modules, .git 등)이 빌드 컨텍스트에 포함되지 않도록 합니다.

   ```
   node_modules
   .git
   *.md
   .env
   ```

3. **경량 베이스 이미지 사용**: `alpine` 기반 이미지를 사용하면 이미지 크기를 크게 줄일 수 있습니다.

---

## 2. Docker Compose

### 2-1. Docker Compose란?

Docker Compose는 **여러 개의 컨테이너로 구성된 애플리케이션**을 정의하고 실행하기 위한 도구입니다.

하나의 `docker-compose.yml` (또는 `compose.yml`) 파일에 애플리케이션을 구성하는 모든 서비스를 정의하고,
`docker compose up` 명령 하나로 모든 서비스를 한 번에 시작할 수 있습니다.

---

### 2-2. Docker Compose가 필요한 이유

실제 애플리케이션은 대부분 여러 컴포넌트로 구성됩니다.

예를 들어, 일반적인 웹 애플리케이션은 다음과 같은 구성을 가집니다.

```
┌──────────┐     ┌──────────┐     ┌──────────┐
│  Nginx   │────▶│  App     │────▶│  MySQL   │
│ (Web)    │     │ (API)    │     │  (DB)    │
└──────────┘     └──────────┘     └──────────┘
```

이 구성을 Docker CLI만으로 실행하려면 다음과 같이 여러 명령을 순서대로 실행해야 합니다.

---

```bash
# 네트워크 생성
docker network create app-network

# MySQL 실행
docker run -d --name mysql --network app-network \
  -e MYSQL_ROOT_PASSWORD=secret \
  -e MYSQL_DATABASE=myapp \
  mysql:8.0

# App 실행
docker run -d --name app --network app-network \
  -e DB_HOST=mysql \
  app-image:latest

# Nginx 실행
docker run -d --name nginx --network app-network \
  -p 80:80 \
  nginx:latest
```

컨테이너가 늘어날수록 관리가 복잡해지고, 실행 순서나 환경 변수 관리가 어려워집니다.

---

### 2-3. docker-compose.yml 구조

Docker Compose는 YAML 파일을 사용하여 서비스를 정의합니다.

```yaml
services:
  <서비스명>:
    image: <이미지명>          # 사용할 Docker 이미지
    build: <빌드경로>          # 또는 Dockerfile로 빌드
    ports:                     # 포트 매핑
      - "호스트:컨테이너"
    environment:               # 환경 변수
      - KEY=VALUE
    volumes:                   # 볼륨 마운트
      - 호스트경로:컨테이너경로
    depends_on:                # 의존 서비스 (시작 순서)
      - <다른서비스명>
    networks:                  # 네트워크 연결
      - <네트워크명>

volumes:                       # 볼륨 정의
  <볼륨명>:

networks:                      # 네트워크 정의
  <네트워크명>:
```

---

### 2-4. Docker Compose 주요 명령어

| 명령어 | 설명 |
| --- | --- |
| `docker compose up` | 모든 서비스를 생성하고 시작 |
| `docker compose up -d` | 백그라운드로 모든 서비스 시작 |
| `docker compose down` | 모든 서비스를 중지하고 컨테이너/네트워크 삭제 |
| `docker compose ps` | 실행 중인 서비스 목록 확인 |
| `docker compose logs` | 모든 서비스의 로그 출력 |
| `docker compose logs -f <서비스명>` | 특정 서비스의 로그를 실시간 출력 |
| `docker compose build` | 서비스 이미지 빌드 |
| `docker compose exec <서비스명> sh` | 실행 중인 서비스 컨테이너에 접속 |
| `docker compose stop` | 모든 서비스 중지 (컨테이너 유지) |
| `docker compose restart` | 모든 서비스 재시작 |


---

위 `docker-compose.yml`의 주요 내용을 살펴보겠습니다.

| 항목 | 설명 |
| --- | --- |
| `services` | 3개의 서비스(mysql, app, nginx)를 정의 |
| `depends_on` | 서비스 시작 순서를 지정. mysql → app → nginx 순서로 시작 |
| `healthcheck` | MySQL이 완전히 준비된 후에 app이 시작되도록 헬스체크 설정 |
| `volumes` | `mysql-data` 볼륨을 사용하여 DB 데이터를 영속적으로 보관 |
| `networks` | `app-network`라는 브릿지 네트워크를 생성하여 서비스 간 통신 |
| `environment` | 환경 변수를 통해 DB 접속 정보를 전달 |

---

## 6. 실습 환경 삭제하기

생성된 자원을 삭제하려면 CloudShell 에서 아래 명령어어를 입력해 주세요.

```bash
export IDE_NAME=mzc-kjh

aws cloudformation delete-stack --stack-name eks-workshop-${IDE_NAME}
```

CloudShell이 아닌 CloudFormation에서 직접 Stack 을 선택하여 삭제하셔도 됩니다.

---

## 관련 링크
- [Docker Multi-stage Build 공식 문서](https://docs.docker.com/build/building/multi-stage/)
- [Docker Compose 공식 문서](https://docs.docker.com/compose/)
- [Dockerfile Best Practices](https://docs.docker.com/build/building/best-practices/)
- [Docker Compose File Reference](https://docs.docker.com/reference/compose-file/)
