# Docker 심화

## 사전 조건
- [0. 교육 환경 구성하기](/00_Setup/README.md)를 이용해 생성된 `code-server`에 접속한 상태여야 합니다.

---

## 학습 목표
- Docker 명령어 
- Dockerfile 심화
    - Multi-stage Build를 이용한 이미지 최적화 방법 학습
    - 효율적인 Docker 이미지 빌드 전략 이해
- Docker Compose
    - Docker Compose의 개념과 필요성 이해
    - docker-compose.yml 작성 방법 학습
    - 다중 컨테이너 애플리케이션 구성 및 실행 실습
- AWS ECR에 이미지 업로드 하기
---

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

```dockerfile
# 이 이미지에는 빌드 도구(gcc, make 등)가 모두 포함됨
FROM golang:1.23
WORKDIR /app
COPY . .
RUN go build -o myapp .
CMD ["./myapp"]
```

위 Dockerfile로 생성된 이미지에는 Go 컴파일러와 소스 코드가 모두 포함되어 **이미지 크기가 불필요하게 커집니다.**

---

#### Multi-stage Build로 해결하기

```dockerfile
# ========== Stage 1: 빌드 단계 ==========
FROM golang:1.23 AS builder
WORKDIR /app
COPY . .
RUN go build -o myapp .

# ========== Stage 2: 실행 단계 ==========
FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/myapp .
CMD ["./myapp"]
```

| 단계 | 설명 |
| --- | --- |
| Stage 1 (`builder`) | Go 컴파일러가 포함된 이미지에서 애플리케이션을 빌드 |
| Stage 2 | 경량 Alpine 이미지에 빌드된 바이너리만 복사하여 실행 |

`COPY --from=builder`를 통해 이전 단계에서 생성된 파일만 가져올 수 있습니다.

---

#### Multi-stage Build의 효과

| 항목 | 일반 빌드 | Multi-stage Build |
| --- | --- | --- |
| 이미지 크기 | ~800MB (Go 컴파일러 포함) | ~15MB (Alpine + 바이너리) |
| 보안 | 빌드 도구, 소스 코드 노출 | 실행에 필요한 파일만 포함 |
| 빌드 속도 | 단일 단계 | 레이어 캐싱 활용 가능 |

---

### 1-3. Multi-stage Build 활용 패턴

#### Node.js 애플리케이션 예시

```dockerfile
# Stage 1: 의존성 설치 및 빌드
FROM node:lts-alpine AS builder
WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile
COPY . .
RUN yarn build

# Stage 2: 실행
FROM node:lts-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./
CMD ["node", "dist/index.js"]
EXPOSE 3000
```

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

## 3. 실습 #1 - Multi-stage Build

### 실습 목표
1. Multi-stage Build를 이용해 최적화된 Docker 이미지를 생성합니다.
2. 일반 빌드와 Multi-stage Build의 이미지 크기를 비교합니다.

---

### 3-1. 실습용 Go 애플리케이션 작성

1. `code-server`에 접속합니다.

2. `terminal`을 실행하고, 실습 디렉토리를 생성합니다.
   ```bash
   mkdir -p ~/environment/eks-edu/01_01_docker/multi-stage-app
   cd ~/environment/eks-edu/01_01_docker/multi-stage-app
   ```

---

3. 간단한 Go 웹 서버 파일(`main.go`)을 생성합니다.
   ```go
   package main

   import (
       "fmt"
       "net/http"
   )

   func main() {
       http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
           fmt.Fprintf(w, "Hello, Multi-stage Build!")
       })
       fmt.Println("Server is running on port 8080...")
       http.ListenAndServe(":8080", nil)
   }
   ```

---

4. Go 모듈 파일(`go.mod`)을 생성합니다.
   ```
   module multi-stage-app

   go 1.23
   ```

---

### 3-2. 일반 Dockerfile로 빌드하기

1. `Dockerfile.normal` 파일을 생성합니다.
   ```dockerfile
   FROM golang:1.23
   WORKDIR /app
   COPY . .
   RUN go build -o myapp .
   CMD ["./myapp"]
   EXPOSE 8080
   ```

2. 이미지를 빌드합니다.
   ```bash
   docker build -t go-app-normal -f Dockerfile.normal .
   ```

---

### 3-3. Multi-stage Dockerfile로 빌드하기

1. `Dockerfile.multistage` 파일을 생성합니다.
   ```dockerfile
   # Stage 1: 빌드
   FROM golang:1.23 AS builder
   WORKDIR /app
   COPY . .
   RUN CGO_ENABLED=0 GOOS=linux go build -o myapp .

   # Stage 2: 실행
   FROM alpine:latest
   WORKDIR /app
   COPY --from=builder /app/myapp .
   CMD ["./myapp"]
   EXPOSE 8080
   ```

2. 이미지를 빌드합니다.
   ```bash
   docker build -t go-app-multistage -f Dockerfile.multistage .
   ```

---

### 3-4. 이미지 크기 비교

두 이미지의 크기를 비교해 보겠습니다.

```bash
docker images | grep go-app
```

아래와 유사한 결과가 출력됩니다.

```
REPOSITORY          TAG       IMAGE ID       CREATED          SIZE
go-app-multistage   latest    abc123def456   10 seconds ago   15MB
go-app-normal       latest    789ghi012jkl   30 seconds ago   800MB
```

Multi-stage Build를 사용한 이미지가 약 **50배 이상 작은 것**을 확인할 수 있습니다. 🎉

---

### 3-5. Multi-stage Build 이미지 실행 및 확인

1. 컨테이너를 실행합니다.
   ```bash
   docker run -d -p 127.0.0.1:8080:8080 --name go-multistage go-app-multistage
   ```

2. 정상 동작을 확인합니다.
   ```bash
   curl http://localhost:8080
   ```

   아래와 같은 응답이 출력되면 정상입니다.
   ```
   Hello, Multi-stage Build!
   ```

---

3. 실행 중인 컨테이너를 확인합니다.
   ```bash
   docker ps
   ```

4. 확인이 완료되면 컨테이너를 정리합니다.
   ```bash
   docker stop go-multistage
   docker rm go-multistage
   ```

---

## 4. 실습 #2 - Docker Compose

### 실습 목표
1. Docker Compose를 이용해 다중 컨테이너 애플리케이션을 구성합니다.
2. 웹 서버(Nginx) + 애플리케이션(Node.js) + 데이터베이스(MySQL) 구성을 실습합니다.

---

### 4-1. 실습용 디렉토리 구성

1. 실습 디렉토리를 생성합니다.
   ```bash
   mkdir -p ~/environment/eks-edu/01_01_docker/compose-app/{app,nginx}
   cd ~/environment/eks-edu/01_01_docker/compose-app
   ```

2. 최종 디렉토리 구조는 다음과 같습니다.
   ```
   compose-app/
   ├── app/
   │   ├── index.js
   │   ├── package.json
   │   └── Dockerfile
   ├── nginx/
   │   └── default.conf
   └── docker-compose.yml
   ```

---

### 4-2. Node.js 애플리케이션 작성

1. `app/package.json` 파일을 생성합니다.
   ```json
   {
     "name": "compose-demo-app",
     "version": "1.0.0",
     "main": "index.js",
     "dependencies": {
       "express": "^4.18.0",
       "mysql2": "^3.6.0"
     }
   }
   ```

---

2. `app/index.js` 파일을 생성합니다.
   ```javascript
   const express = require('express');
   const mysql = require('mysql2/promise');

   const app = express();
   const PORT = 3000;

   // MySQL 연결 설정
   const dbConfig = {
     host: process.env.DB_HOST || 'mysql',
     user: process.env.DB_USER || 'appuser',
     password: process.env.DB_PASSWORD || 'apppassword',
     database: process.env.DB_NAME || 'composedb'
   };

   // 헬스체크 엔드포인트
   app.get('/health', (req, res) => {
     res.json({ status: 'ok', timestamp: new Date().toISOString() });
   });

   // 메인 엔드포인트
   app.get('/', async (req, res) => {
     try {
       const connection = await mysql.createConnection(dbConfig);
       const [rows] = await connection.execute('SELECT NOW() as current_time');
       await connection.end();
       res.json({
         message: 'Docker Compose 실습에 오신 것을 환영합니다!',
         db_time: rows[0].current_time,
         hostname: require('os').hostname()
       });
     } catch (error) {
       res.status(500).json({
         message: 'DB 연결 실패',
         error: error.message
       });
     }
   });

   app.listen(PORT, () => {
     console.log(`App server is running on port ${PORT}`);
   });
   ```

---

3. `app/Dockerfile` 파일을 생성합니다.
   ```dockerfile
   FROM node:lts-alpine
   WORKDIR /app
   COPY package.json ./
   RUN npm install --production
   COPY . .
   CMD ["node", "index.js"]
   EXPOSE 3000
   ```

---

### 4-3. Nginx 설정 파일 작성

`nginx/default.conf` 파일을 생성합니다.

```nginx
upstream app_server {
    server app:3000;
}

server {
    listen 80;

    location / {
        proxy_pass http://app_server;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

이 설정은 Nginx가 80번 포트로 들어오는 요청을 Node.js 애플리케이션(app:3000)으로 전달하는 리버스 프록시 역할을 합니다.

---

### 4-4. docker-compose.yml 작성

`docker-compose.yml` 파일을 생성합니다.

```yaml
services:
  # MySQL 데이터베이스
  mysql:
    image: mysql:8.0
    container_name: compose-mysql
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: composedb
      MYSQL_USER: appuser
      MYSQL_PASSWORD: apppassword
    volumes:
      - mysql-data:/var/lib/mysql
    networks:
      - app-network
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Node.js 애플리케이션
  app:
    build: ./app
    container_name: compose-app
    environment:
      DB_HOST: mysql
      DB_USER: appuser
      DB_PASSWORD: apppassword
      DB_NAME: composedb
    depends_on:
      mysql:
        condition: service_healthy
    networks:
      - app-network

  # Nginx 웹 서버 (리버스 프록시)
  nginx:
    image: nginx:latest
    container_name: compose-nginx
    ports:
      - "127.0.0.1:8080:80"
    volumes:
      - ./nginx/default.conf:/etc/nginx/conf.d/default.conf
    depends_on:
      - app
    networks:
      - app-network

volumes:
  mysql-data:

networks:
  app-network:
    driver: bridge
```

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

### 4-5. Docker Compose로 실행하기

1. `compose-app` 디렉토리에서 모든 서비스를 시작합니다.
   ```bash
   cd ~/environment/eks-edu/01_01_docker/compose-app
   docker compose up -d
   ```

   아래와 유사한 출력이 표시됩니다.
   ```
   [+] Running 4/4
    ✔ Network compose-app_app-network  Created
    ✔ Volume "compose-app_mysql-data"  Created
    ✔ Container compose-mysql          Healthy
    ✔ Container compose-app            Started
    ✔ Container compose-nginx          Started
   ```

---

2. 모든 서비스가 정상적으로 실행되었는지 확인합니다.
   ```bash
   docker compose ps
   ```

   3개의 서비스가 모두 `running` 상태여야 합니다.

---

3. 애플리케이션이 정상 동작하는지 확인합니다.

   헬스체크 엔드포인트를 호출합니다.
   ```bash
   curl http://localhost:8080/health
   ```

   아래와 같은 응답이 출력되면 정상입니다.
   ```json
   {"status":"ok","timestamp":"2025-04-28T09:00:00.000Z"}
   ```

---

   메인 엔드포인트를 호출합니다.
   ```bash
   curl http://localhost:8080/
   ```

   아래와 같이 DB 연결 시간과 함께 응답이 출력되면 모든 서비스가 정상적으로 연동된 것입니다. 🎉
   ```json
   {
     "message": "Docker Compose 실습에 오신 것을 환영합니다!",
     "db_time": "2025-04-28T09:00:00.000Z",
     "hostname": "abc123def456"
   }
   ```

---

### 4-6. 서비스 로그 확인하기

각 서비스의 로그를 확인할 수 있습니다.

1. 모든 서비스의 로그를 한 번에 확인합니다.
   ```bash
   docker compose logs
   ```

2. 특정 서비스의 로그만 실시간으로 확인합니다.
   ```bash
   docker compose logs -f app
   ```

3. 로그 확인을 종료하려면 `Ctrl + C`를 누릅니다.

---

### 4-7. 서비스 컨테이너에 접속하기

실행 중인 서비스 컨테이너에 직접 접속하여 내부를 확인할 수 있습니다.

1. MySQL 컨테이너에 접속하여 데이터베이스를 확인합니다.
   ```bash
   docker compose exec mysql mysql -u appuser -papppassword composedb
   ```

   MySQL 프롬프트가 표시되면 아래 명령을 실행해 봅니다.
   ```sql
   SHOW DATABASES;
   SELECT NOW();
   EXIT;
   ```

---

2. App 컨테이너에 접속하여 환경 변수를 확인합니다.
   ```bash
   docker compose exec app sh
   ```

   컨테이너 내부에서 환경 변수를 확인합니다.
   ```bash
   echo $DB_HOST
   echo $DB_NAME
   exit
   ```

---

## 5. Docker Compose 심화

### 5-1. 환경 변수 파일 (.env) 활용

`docker-compose.yml`에 직접 환경 변수를 작성하는 대신, `.env` 파일을 사용하여 관리할 수 있습니다.

1. `compose-app` 디렉토리에 `.env` 파일을 생성합니다.
   ```bash
   cd ~/environment/eks-edu/01_01_docker/compose-app
   ```

   ```env
   MYSQL_ROOT_PASSWORD=rootpassword
   MYSQL_DATABASE=composedb
   MYSQL_USER=appuser
   MYSQL_PASSWORD=apppassword
   APP_PORT=3000
   NGINX_PORT=8080
   ```

---

2. `docker-compose.yml`에서 `.env` 파일의 변수를 참조할 수 있습니다.
   ```yaml
   services:
     mysql:
       image: mysql:8.0
       environment:
         MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
         MYSQL_DATABASE: ${MYSQL_DATABASE}
         MYSQL_USER: ${MYSQL_USER}
         MYSQL_PASSWORD: ${MYSQL_PASSWORD}
   ```

   `.env` 파일은 `docker-compose.yml`과 같은 디렉토리에 위치하면 자동으로 로드됩니다.

---

### 5-2. Docker Compose 프로필(Profile)

프로필을 사용하면 개발/운영 환경에 따라 특정 서비스만 선택적으로 실행할 수 있습니다.

```yaml
services:
  app:
    build: ./app
    # ... (기존 설정)

  mysql:
    image: mysql:8.0
    # ... (기존 설정)

  # 개발 환경에서만 사용하는 DB 관리 도구
  adminer:
    image: adminer:latest
    ports:
      - "127.0.0.1:9090:8080"
    profiles:
      - debug
    depends_on:
      - mysql
    networks:
      - app-network
```

---

```bash
# 기본 서비스만 실행 (adminer 제외)
docker compose up -d

# debug 프로필 포함하여 실행 (adminer 포함)
docker compose --profile debug up -d
```

---

## 6. 실습 환경 삭제하기

실습이 모두 완료되었다면, 실습 중 생성한 리소스들을 삭제하여 환경을 정리합니다.

---

### 6-1. Docker Compose 서비스 삭제

Docker Compose로 실행한 모든 서비스를 중지하고 삭제합니다.

```bash
cd ~/environment/eks-edu/01_01_docker/compose-app
docker compose down -v
```

| 옵션 | 설명 |
| --- | --- |
| `down` | 모든 서비스를 중지하고 컨테이너, 네트워크를 삭제 |
| `-v` | 생성된 볼륨(mysql-data)도 함께 삭제 |

---

### 6-2. Multi-stage Build 실습 이미지 삭제

```bash
docker rmi go-app-normal go-app-multistage
```

---

### 6-3. Docker Compose 실습 이미지 삭제

```bash
docker rmi compose-app-app
```

사용하지 않는 이미지를 일괄 삭제하려면 아래 명령을 사용합니다. (선택사항)
```bash
docker image prune -a
```

---

### 6-4. 실습 디렉토리 삭제 (선택사항)

실습에서 생성한 소스 파일을 삭제합니다.
```bash
rm -rf ~/environment/eks-edu/01_01_docker/multi-stage-app
rm -rf ~/environment/eks-edu/01_01_docker/compose-app
```

---

## 관련 링크
- [Docker Multi-stage Build 공식 문서](https://docs.docker.com/build/building/multi-stage/)
- [Docker Compose 공식 문서](https://docs.docker.com/compose/)
- [Dockerfile Best Practices](https://docs.docker.com/build/building/best-practices/)
- [Docker Compose File Reference](https://docs.docker.com/reference/compose-file/)
