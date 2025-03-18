# 사전 조건


# 기본 환경에 설치가 필요로 한 부분 ( 공통 )
1. kubectl
2. helm
3. aws cli v2

## 1차에 필요로한 프로그램
1. docker
2. kind

## 작업 절차
### 실습
1. vscode server 생성
```
$ sh 01_create_vscode_server.sh
```
2. vscode server URL 찾기
```
$ sh 02_get_output.sh | jq -r '.[] | select(.OutputKey=="IdeUrl") | .OutputValue'
```
3. 패스워드 찾기
```
$ sh 03_get_password.sh
```
4. 2번 사이트에서 3번의 패스워드를 입력하여 로그인