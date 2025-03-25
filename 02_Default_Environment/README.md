# 학습 목표
- 강의 진행을 위해 기본 인프라 및 EKS Cluster 생성에 대해 익숙해 지기 위한 생성 실습

# 학습 절차
## 사전 조건
1. 01_Container/01_create_vscode_server.sh 코드가 실행되어 있어야 함
2. vscode server 내에서 실행되어야 함

## 기본 Infra 배포
- VPC, Public Subnet 2개, Pivate Subnet 2개, IGW, NatGateway
- 01장 01_create_vscode_server.sh 에서 기본 인프라도 생성

## eksctl
### eksctl이란
- eksclt은 관리형 Kubernetes 서비스인 EKS에서 클러스터를 만들고 관리하기 위해 Weaveworks 에서 만든 CLI Tool
- Weaveworks가 상업중 운영을 중단한다고 하여, 현재는 AWS에서 인수한 상태

## 실습
1. 기본 인프라 생성 ( VPC / Public Subnet / Private Subnet ) 
```
$ sh 01_default_vpc.sh
```

2. env.sh.sample 파일로  env.sh 를 만들어서, 생성된 정보 세팅
```
$ mv env.sh.sample env.sh

$ cat 02_get_output.sh

# env.sh에 세팅
# sh 02_get_output.sh | jq -r '.[] | select(.OutputKey=="VpcId") | .OutputValue'
export VPC_ID=
# sh ../01_Container/02_get_output.sh | jq -r '.[] | select(.OutputKey=="PrivateSubnet01AZ") | .OutputValue'
export AWS_AZ1=
# sh ../01_Container/02_get_output.sh | jq -r '.[] | select(.OutputKey=="PrivateSubnet02AZ") | .OutputValue'
export AWS_AZ2=
# sh ../01_Container/02_get_output.sh | jq -r '.[] | select(.OutputKey=="PrivateSubnet01") | .OutputValue'
export AWS_PRIVATE_SUBNET1=
# sh ../01_Container/02_get_output.sh | jq -r '.[] | select(.OutputKey=="PrivateSubnet01AZ") | .OutputValue'
export AWS_PRIVATE_SUBNET2=
# sh 02_get_output.sh | jq -r '.[] | select(.OutputKey=="SecurityGroups") | .OutputValue'
export EKS_ADDITIONAL_SG=
```
### 관련 링크