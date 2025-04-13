# Access 관리 - 워크로드 액세스

## 사전 조건

1. [0. 교육 환경 구성하기](/00_Setup/)를 이용해 기본 실습 환경 생성이 되어 있어야 합니다.
2. [0. 교육 환경 구성하기](/00_Setup/)를 이용해 생성된 `code-server`에 접속한 상태여야 합니다.
3. [3. 기본 환경 생성](/03_Default_Environment/)에 vpc와 eks를 배포해야 합니다.
   ```shell
   cd ~/environment/eks-edu/03_Default_Environment/01_create_vpc
   sh 01_default_vpc.sh

   cd ../02_create_eks
   sh 01-3_make_eksctl_cluster_nodegroup_pod_identity_template.sh
   sh 02_eksctl_install.sh
   ```

## 학습 목표

- Pod에 AWS 리소스 접근 권한을 부여할 수 있다.

## 이론

### IRSA란 ?

- Pod의 컨테이너에 있는 애플리케이션은 **AWS SDK 또는 AWS CLI를 사용하여 AWS ID 및 액세스 관리(IAM) 권한을 사용하여 AWS 서비스에 API 요청**을 할 수 있다.
- 애플리케이션은 **AWS 자격 증명으로 AWS API 요청에 서명**해야 합니다.
- 서비스 계정에 대한 **IAM 역할(IRSA)은 Amazon EC2 인스턴스 프로파일이 Amazon EC2 인스턴스에 자격 증명을 제공하는 것과 비슷한 방식**으로 애플리케이션에 대한 자격 증명을 관리하는 기능을 제공합니다.
- AWS 자격 증명을 생성하여 컨테이너에 배포하거나 **Amazon EC2 인스턴스의 역할을 사용하는 대신에 IAM 역할을 Kubernetes 서비스 계정과 연결하고 서비스 계정을 사용**하도록 포드를 구성합니다.
#### IRSA 이점
- 최소 권한 : **IAM 권한의 범위를 서비스 계정으로 지정**할 수 있습니다. 그러면 해당 서비스 계정을 사용하는 포드만 이 권한에 액세스 할 수 있습니다. 또한 이 기능을 사용하면 kiam, kube2iam 같은 타사 솔루션이 필요 없습니다.
- 자격 증명 격리 : 포드의 컨테이너는 컨테이너가 사용하는 서비스 계정과 연결된 IAM 역할에 대한 자격증명만 검색할 수 있습니다. 컨테이너는 다른 포드의 다른 컨테이너에서 사용하는 자격 증명에 액세스할 수 없습니다. 서비스 계정에 IAM 역할을 사용하는 경우 Amazon EC2 인스턴스 메타데이터 서비스(IMDS)에 대한 포드 액세스를 차단하지 않는 한 컨테이너에도 Amazon EKS 노드 IAM 역할에 할당된 권한이 있습니다.
- 감사 : **AWS CloudTrail을 통한 액세스 및 이벤트 로깅을 사용하여 사후 감사**를 지원합니다.

### Pod Identity 란
- 각 EKS Pod Identity 연결은 지정된 **클러스터의 네임스페이스에 있는 서비스 계정에 역할을 매핑**합니다.
- **여러 클러스터에 동일한 애플리케이션이 있는 경우 역할의 신뢰 정책을 수정하지 않고도 각 클러스터에서 동일한 연결을 만들수** 있습니다.
- 포드가 연결이 있는 서비스 계정을 사용하는 경우 Amazon EKS는 **포드의 컨테이너에 환경 변수를 설정**합니다.
- 환경 변수는 **AWS CLI를 포함한 AWS SDK를 구성하여 EKS 포드 ID 자격 증명을 사용**합니다.

#### Pod Identity 이점
- 최소 권한 : IAM 권한을 서비스 계정으로 범위 지정할 수 있으며, 해당 서비스 계정을 사용하는 Pod만 해당 권한에 액세스할 수 있습니다. 이 기능은 **타사 솔루션의 필요성도 없애**줍니다.
- 자가 증명 격리 : Pod의 컨테이너는 컨테이너가 사용하는 서비스 계정과 연결된 IAM 역할에 대한 자격 증명만 검색할 수 있습니다. **컨테이너는 다른 Pod의 다른 컨테이너에서 사용하는 자격 증명에 액세스할 수 없습**니다. Pod ID를 사용할 때 Pod의 컨테이너는 Amazon EC2 Instance Metadata Service(IMDS) 에 대한 Pod 액세스를 차단하지 않는 한 Amazon EKS 노드 IAM 역할 에 할당된 권한도 갖습니다 .
- 감사 가능성 : **AWS CloudTrail을 통해 액세스 및 이벤트 로깅이 가능하여 회고적 감사를 용이**하게 할 수 있습니다.

## 실습
### IRSA 구성도
![구성도](image/irsa_overview.png)

### Pod에 IRSA 권한 적용
1. OIDC 값 가져오기

   ```shell
   cd ~/environment/eks-edu/06_Workload_Access_2/01_app_irsa
   sh 01_get_oidc.sh
   ```

   위 `01_get_oidc.sh`를 실행하면 아래 aws cli 가 실행됩니다.(참고용)

   ```shell
   aws eks describe-cluster --name eks-edu-cluster-9641173 --query cluster.identity.oidc.issuer --output text --no-cli-pager  | cut -d '/' -f 5
   ```
2. 실행 화면

   ![alt text](image/get_oidc.png)

3. 생성 결과 화면

   ![alt text](image/result_get_oidc.png)

4. pod에서 접근하고자 하는 S3 bucket 생성

   ```shell
   cd ~/environment/eks-edu/06_Workload_Access_2/01_app_irsa
   sh 02_create_bucket.sh
   ```

   위 `02_create_bucket.sh`를 실행하면 아래 aws cli 가 실행됩니다.(참고용)

   ```shell
   # s3 bucket 존재 여부 체크
   aws s3api head-bucket --bucket pod-secrets-bucket-9641173

   # s3 bucket 생성
   aws s3api create-bucket --bucket pod-secrets-bucket-9641173 \
                --region ap-northeast-1 \
                --create-bucket-configuration LocationConstraint=ap-northeast-1
   ```
5. 실행 화면

   ![alt text](image/create_bucket.png)

6. 생성 결과 화면

   ![alt text](image/result_create_bucket.png)

7. S3에 Object을 읽을 수 있는 Policy 생성

   ```shell
   cd ~/environment/eks-edu/06_Workload_Access_2/01_app_irsa
   sh 03_irsa_create_policy.sh
   ```

   위 `03_irsa_create_policy.sh`를 실행하면 아래 aws cli 가 실행됩니다.(참고용)

   ```shell
   >> tmp/irsa-workload-policy.json
   {
       "Version": "2012-10-17",
       "Statement": [
           {
               "Effect": "Allow",
               "Action": "s3:GetObject",
               "Resource": "arn:aws:s3:::pod-secrets-bucket-9641173"
           }
       ]
   }

   aws iam create-policy --policy-name eks-edu-irsa-workload-policy-9641173 \
    --policy-document file://tmp/irsa-workload-policy.json
   ```

8. 실행 화면

   ![alt text](image/irsa_create_policy.png)

9. 생성 결과 화면

   ![alt text](image/result_irsa_create_policy.png)

10. App 배포시 사용할 service account 생성

    ```shell
    cd ~/environment/eks-edu/06_Workload_Access_2/01_app_irsa
    sh 04_irsa_create_account.sh
    ```

    위 `04_irsa_create_account.sh`를 실행하면 아래 kubectl cli 가 실행됩니다.(참고용)

    ```shell
    >> tmp/eks-edu-irsa-service-account.yaml
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: eks-edu-irsa-service-account-9641173
      namespace: default

    kubectl apply -f tmp/eks-edu-irsa-service-account.yaml
    ```
11. 실행 화면

    ![alt text](image/irsa_create_account.png)

12. 생성 결과 화면

    ![alt text](image/result_irsa_create_account.png)

13. Role 생성

    ```shell
    cd ~/environment/eks-edu/06_Workload_Access_2/01_app_irsa
    sh 05_create_role.sh
    ```

    위 `05_create_role.sh`를 실행하면 아래 aws cli 가 실행됩니다.(참고용)

    ```shell
    >>tmp/trust-relationship.json
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "Federated": "arn:aws:iam::539666729110:oidc-provider/oidc.eks..amazonaws.com/id/6C602CB94089F9B90D056D1D92D47CBE"
         },
         "Action": "sts:AssumeRoleWithWebIdentity",
         "Condition": {
           "StringEquals": {
             "oidc.eks.ap-northeast-1.amazonaws.com/id/6C602CB94089F9B90D056D1D92D47CBE:aud": "sts.amazonaws.com",
             "oidc.eks.ap-northeast-1.amazonaws.com/id/6C602CB94089F9B90D056D1D92D47CBE:sub": "system:serviceaccount:default:eks-edu-service-account-9641173"
            }
          }
        }
      ]
    }
   
    # Role 생성
    aws iam create-role \
       --role-name eks-edu-irsa-workload-role-9641173 \
        --assume-role-policy-document file://tmp/trust-relationship.json \
        --description eks-edu-irsa-workload-role-9641173-description

    # 생성했던 Policy를 연동
    aws iam attach-role-policy \
       --role-name eks-edu-irsa-workload-role-9641173 \
       --policy-arn=arn:aws:iam::539666729110:policy/eks-edu-irsa-workload-policy-9641173
    ```

14. 실행 화면

    ![alt text](image/create_role.png)

15. 생성 결과 화면

    ![alt text](image/result_create_role.png)

16. Service Account에 role annotation 연동하기

    ```shell
    cd ~/environment/eks-edu/06_Workload_Access_2/01_app_irsa
    sh 06_annotate_serviceaccount.sh
    ```

    위 `06_annotate_serviceaccount.sh`를 실행하면 아래 kubectl cli 가 실행됩니다.(참고용)

    ```shell
    kubectl -n default annotate serviceaccount eks-edu-irsa-service-account-9641173 \
       eks.amazonaws.com/role-arn=arn:aws:iam::539666729110:role/eks-edu-workload-role-9641173
    ```

17. 실행 화면

    ![alt text](image/annotate_serviceaccount.png)

18. 생성 결과 화면

    ![alt text](image/result_annotate_serviceaccount.png)

19. deployment 배포

    ```shell
    cd ~/environment/eks-edu/06_Workload_Access_2/01_app_irsa
    sh 07_irsa_create_deploy.sh
    ```

    위 `07_irsa_create_deploy.sh`를 실행하면 아래 kubectl cli 가 실행됩니다.(참고용)

    ```shell
    >>tmp/irsa-deployment.yaml을 배포
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: irsa-app
      namespace: default
    spec:
      selector:
        matchLabels:
          app: irsa-app
      template:
        metadata:
          labels:
            app: irsa-app
        spec:
          serviceAccountName: eks-edu-irsa-service-account-9641173
          containers:
          - name: my-app
            image: public.ecr.aws/nginx/nginx:1.27

    kubectl apply -f tmp/irsa-deployment.yaml
    ```

20. 실행 화면

    ![alt text](image/irsa_create_deploy.png)

21. 생성 결과 화면

    ![alt text](image/result_irsa_create_deploy.png)

22. irsa에 잘 적용되었는지 확인

    ```shell
    cd ~/environment/eks-edu/06_Workload_Access_2/01_app_irsa
    sh 08_irsa_check.sh
    ```

    위 `08_irsa_check.sh`를 실행하면 아래 kubectl cli 가 실행됩니다.(참고용)

    ```shell
    # irsa pods 배포 상태
    kubectl get pods -l app=irsa-app

    # pod에 AWS_ROLE_ARN 환경 변수가 있는지 확인
    kubectl describe pod/irsa-app-57c768dd9d-vxqkt | grep AWS_ROLE_ARN:

    # pod에 AWS_WEB_IDENTITY_TOKEN_FILE 환경 변수가 있는지 확인
    kubectl describe pod/irsa-app-57c768dd9d-vxqkt | grep AWS_WEB_IDENTITY_TOKEN_FILE:
    ```

20. 실행 화면

    ![alt text](image/irsa_check.png)

21. 생성 결과 화면

    ![alt text](image/result_irsa_check.png)

### Pod에 Pod Identity 권한 적용
1. S3에 Object을 읽을 수 있는 Policy 생성

   ```shell
   cd ~/environment/eks-edu/06_Workload_Access_2/02_app_pod_identity/
   sh 01_pod_identity_create_policy.sh
   ```

   위 `01_pod_identity_create_policy.sh`를 실행하면 아래 aws cli 가 실행됩니다.(참고용)

   ```shell
   >> tmp/pod-identity-workload-policy.json
   {
       "Version": "2012-10-17",
       "Statement": [
           {
               "Effect": "Allow",
               "Action": "s3:GetObject",
               "Resource": "arn:aws:s3:::pod-secrets-bucket-9641173"
           }
       ]
   }

   aws iam create-policy --policy-name eks-edu-pod-identity-workload-policy-9641173 \
      --policy-document file://tmp/pod-identity-workload-policy.json
   ```

2. 실행 화면

   ![alt text](image/pod_identity_create_policy.png)

3. 생성 결과 화면

   ![alt text](image/result_pod_identity_create_policy.png)

4. App 배포시 사용할 service account 생성

   ```shell
   cd ~/environment/eks-edu/06_Workload_Access_2/02_app_pod_identity/
   sh 02_pod_identity_create_account.sh
   ```

   위 `02_pod_identity_create_account.sh`를 실행하면 아래 kubectl cli 가 실행됩니다.(참고용)

   ```shell
   >> tmp/eks-edu-pod-identity-service-account.yaml
   apiVersion: v1
   kind: ServiceAccount
   metadata:
     name: eks-edu-pod-identity-service-account-9641173
     namespace: default

   kubectl apply -f tmp/eks-edu-pod-identity-service-account.yaml
   ```

5. 실행 화면

   ![alt text](image/pod_identity_create_account.png)

6. 생성 결과 화면

   ![alt text](image/result_pod_identity_create_account.png)

7. Role 생성

   ```shell
   cd ~/environment/eks-edu/06_Workload_Access_2/02_app_pod_identity
   sh 03_pod_identity_create_role.sh
   ```

   위 `03_pod_identity_create_role.sh`를 실행하면 아래 aws cli 가 실행됩니다.(참고용)

   ```shell
   >>tmp/pod-identity-trust-relationship.json
   {
       "Version": "2012-10-17",
       "Statement": [
           {
               "Sid": "AllowEksAuthToAssumeRoleForPodIdentity",
               "Effect": "Allow",
               "Principal": {
                   "Service": "pods.eks.amazonaws.com"
               },
               "Action": [
                   "sts:AssumeRole",
                   "sts:TagSession"
               ]
           }
       ]
   }
   
   # Role 생성
   aws iam create-role \
      --role-name eks-edu-pod-identity-workload-role-9641173 \
      --assume-role-policy-document file://tmp/pod-identity-trust-relationship.json \
      --description eks-edu-pod-identity-workload-role-9641173-description

   # S3에 GetObject 권한이 있던 Policy를 연동
   aws iam attach-role-policy \
      --role-name eks-edu-pod-identity-workload-role-9641173 \
      --policy-arn=arn:aws:iam::539666729110:policy/eks-edu-pod-identity-workload-policy-9641173
   ```

8. 실행 화면

   ![alt text](image/pod_identity_create_role.png)

9. 생성 결과 화면

   ![alt text](image/result_pod_identity_create_role.png)

10. Role 과 Service Account 연동

    ```shell
    cd ~/environment/eks-edu/06_Workload_Access_2/02_app_pod_identity
    sh 04_pod_identity_association.sh
    ```

    위 `04_pod_identity_association.sh`를 실행하면 아래 aws cli 가 실행됩니다.(참고용)

    ```shell
    # Role과 Service Account 연동
    aws eks create-pod-identity-association \
       --cluster-name eks-edu-cluster-9641173 \
       --role-arn arn:aws:iam::539666729110:role/eks-edu-pod-identity-workload-role-9641173 \
       --namespace default \
       --service-account eks-edu-pod-identity-service-account-9641173
    ```

11. 실행 화면

    ![alt text](image/pod_identity_association.png)

12. 생성 결과 화면

    ![alt text](image/result_pod_identity_association.png)   

13. deployment 배포

    ```shell
    cd ~/environment/eks-edu/06_Workload_Access_2/02_app_pod_identity
    sh 05_pod_identity_create_deploy.sh
    ```

    위 `05_pod_identity_create_deploy.sh`를 실행하면 아래 kubectl cli 가 실행됩니다.(참고용)

    ```shell
    >>tmp/irsa-deployment.yaml을 배포
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: pod-identity-app
    spec:
      selector:
        matchLabels:
          app: pod-identity-app
      template:
        metadata:
          labels:
            app: pod-identity-app
        spec:
          serviceAccountName: eks-edu-pod-identity-service-account-9641173
          containers:
          - name: my-app
            image: public.ecr.aws/nginx/nginx:1.27

    kubectl apply -f tmp/pod-identity-deployment.yaml
    ```

14. 실행 화면

    ![alt text](image/pod_identity_create_deploy.png)

15. 생성 결과 화면

    ![alt text](image/result_pod_identity_create_deploy.png)

16. pod 에 권한이 설정되었는지 확인

    ```shell
    cd ~/environment/eks-edu/06_Workload_Access_2/02_app_pod_identity
    sh 06_pod_identity_check.sh
    ```

    위 `06_pod_identity_check.sh`를 실행하면 아래 kubectl cli 가 실행됩니다.(참고용)

    ```shell
    # Pod 이름 조회
    kubectl -n default get pods -l app=pod-identity-app -oname

    kubectl -n default describe pod/pod-identity-app-7c6dfc9789-hg2ts | grep AWS_CONTAINER_AUTHORIZATION_TOKEN_FILE
    ```

17. 실행 화면

    ![alt text](image/pod_identity_check.png)

18. 생성 결과 화면

    ![alt text](image/result_pod_identity_check.png)

### IRSA에서 Pod Identity Migration
- 숙제

## 정리

1. 리소스 삭제

   ```shell
   cd ~/environment/eks-edu/06_Workload_Access_2/99_delete
   sh 99_delete.sh
   ```

   위 `99_delete.sh`를 실행하면 아래 aws cli가 실행됩니다. (참고용)

   ```shell
   aws iam detach-role-policy --role-name eks-edu-irsa-workload-role-9641173 --policy-arn arn:aws:iam::539666729110:policy/eks-edu-irsa-workload-policy-9641173 
   aws iam delete-role --role-name eks-edu-irsa-workload-role-9641173 
   aws iam detach-role-policy --role-name eks-edu-pod-identity-workload-role-9641173 --policy-arn arn:aws:iam::539666729110:policy/eks-edu-pod-identity-workload-policy-9641173 
   aws iam delete-role --role-name eks-edu-pod-identity-workload-role-9641173
   aws s3 rm s3://pod-secrets-bucket-9641173 --recursive 
   aws s3 rb s3://pod-secrets-bucket-9641173
   ```

2. 실행 화면

   ![alt text](image/delete_resource.png)

3. 결과 화면
   
   Role 삭제 확인
   ![alt text](image/result_delete_role.png)

   Policy 삭제 확인
   ![alt text](image/result_delete_policy.png)
   
   S3 버킷 삭제 확인
   ![alt text](image/result_delete_bucket.png)

4. EKS 삭제는 03_Default_Environment 에서 삭제 진행

   ```shell
   cd ../../03_Default_Environment/99_delete
   sh 99_delete.sh
   ```

## 관련 링크

- [서비스 계정에 대한 IAM 역할](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/iam-roles-for-service-accounts.html)
- [EKS Pod Identity가 포드에 AWS 서비스에 대한 액세스 권한을 부여하는 방법 알아보기](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/pod-identities.html)