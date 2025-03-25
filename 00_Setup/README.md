# 0. 교육 환경 구성하기

EKS 교육 진행을 위해 먼저, 사용하실 AWS 계정에 `code-server` 및 관련 기초 인프라를 생성해야 합니다.

AWS에 로그인 한 후, CloudShell로 이동하여 다음 명령어를 입력해 주세요.

1. 지역 선택
   
   ![지역선택](./images/region.png)

2. CloudShell로 이동
   
   ![CloudShell](./images/cloudshell.png)

3. `code-server` 생성용 CloudFormation 실행

   `EKS_ID` 환경 변수에 사용하기를 원하는 ID를 지정합니다.
   `EKS_ID` 변수는 `code-server` 생성용 CloudFormation에 사용됩니다.
   ```shell
   export EKS_ID=mzc-kjh
   ```

   CloudShell 에서 아래 명령을 실행하여 `code-server` 생성을 위한 CloudFormation Stack을 생성합니다. (대략 10분 정도 소요됩니다.)

   ```shell
   aws cloudformation create-stack \
       --stack-name eks-workshop-${EKS_ID} \
       --template-body "$(curl -fsSL https://raw.githubusercontent.com/megazone-stc-cnp/eks-edu/refs/heads/main/eks-workshop-vscode-cfn.yaml)" \
       --capabilities CAPABILITY_NAMED_IAM \
       --region ${AWS_REGION}
   ```
   ![AWS CLI - CloudFormation](./images/aws-cli-cloudformation.png)

   CloudFormation으로 이동하여 `eks-workshop-${EKS_ID}` 스택의 상태를 확인하여 `CREATE_COMPLETE`가 될때까지 기다립니다.

   ![AWS - CloudFormation검색](./images/aws-cloudformation-1.png)

   ![AWS - CloudFormation Stack](./images/aws-cloudformation-2.png)
   
   CloudFormation의 출력(Outputs) 탭에서 code-server 접속을 위한 정보를 확인할 수 있습니다.

   ![AWS - CloudFormation Outputs](./images/aws-cloudformation-outputs.png)

   - `IdeUrl`에는 `code-server` IDE를 접속할 수 있는 URL입니다.
   
   - `IdePasswordSecret`에는 `code-server` IDE 접속 시 사용할 비밀번호가 저장된 AWS Secrets Manager의 보안 암호를 확인할 수 있는 링크입니다.

4. `code-server` 접속
   
   `code-server` 접속 비밀번호를 얻기위해 `IdePasswordSecret` 링크를 클릭하여 AWS Secrets Manager로 이동한 후, `개요` 탭에서 `보안 암호 값 검색`(Retrieve secret value) 버튼을 클립합니다.

   ![AWS - SecretsManager Overview](./images/aws-secretsmanager-secret-1.png)

   화면에 표시된 비밀번호를 복사합니다.

   ![AWS - SecretsManager Secret](./images/aws-secretsmanager-secret-2.png)

   CloudFormation의 `IdeUrl` 링크를 클릭한 후, 비밀번호에 이전에 복사한 비밀번호를 붙여넣기 한 후, `SUBMIT` 버튼을 클릭합니다.

   ![code-server login](./images/code-server-login.png)

   접속 후, 아래와 같은 화면이 뜨면 실습 환경이 정상적으로 생성된 것입니다.🎉🎉🎉
   
   ![code-server main](./images/code-server-main.png)

### 참고-1. `code-server` 에 기본으로 설치되는 프로그램

| Tool | version | release date |
| ---- | ------- | ------------ |
| [docker](https://github.com/moby/moby) | 25.0.8 | 2025-02-05 |
| [docker-compose](https://github.com/docker/compose) | 2.34.0 | ? |
| [aws cli v2](https://aws.amazon.com/ko/cli/) | ? | ? |
| [kubectl](https://kubernetes.io/docs/reference/kubectl/) | 1.31.6 | 2025-02-11 |
| [helm](https://helm.sh) | 3.17.2 | 2025-03-14 |
| [eksctl](https://github.com/eksctl-io/eksctl) | 0.206.0 | 2025-03-23 |
| [kubeseal](https://github.com/bitnami-labs/sealed-secrets) | 0.28.0 | 2025-01-16 |
| [yq](https://github.com/mikefarah/yq) | 4.45.1 | 2025-01-12 |
| [flux](https://github.com/fluxcd) | 2.5.1 | 2025-02-26 |
| [argocd](https://github.com/argoproj/argo-cd) | 2.14.8 | 2025-03-25 |
| [terraform](https://www.terraform.io/) | 1.11.2 | 2025-03-12 |
| [ec2_instance_selector](https://github.com/aws/amazon-ec2-instance-selector) | 3.1.1 | 2025-02-25 |
| [oha](https://github.com/hatoo/oha) | 1.8.0 | 2025-02-15 |