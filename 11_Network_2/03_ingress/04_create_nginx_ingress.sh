#!/bin/bash
if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

if [ ! -f "./local_env.sh" ];then
	echo "local_env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ./local_env.sh
# export VPC_ID=vpc-09effdadb2d737300
# export AWS_AZ1=ap-northeast-1a
# export AWS_AZ2=ap-northeast-1c
# export AWS_PRIVATE_SUBNET1=subnet-03ed17397746222a8
# export AWS_PRIVATE_SUBNET2=subnet-07873917f6e87880b
# export EKS_ADDITIONAL_SG=sg-033a4c5fa9437d100

NAMESPACE_NAME=kube-system
SERVICE_ACCOUNT_NAME=alb-controller-sa
ROLE_NAME=eks-edu-aws-load-balancer-controller-role-${IDE_NAME}
REPO_FULLPATH=public.ecr.aws/eks/aws-load-balancer-controller
ORIGIN_TAG=v2.9.2
ALB_NAME=eks-edu-alb-${IDE_NAME}
SERVICE_NAME=nginx-service
# =============================================================================
if [ ! -d "tmp" ]; then
    mkdir -p tmp
fi
cat >tmp/nginx-ingress.yaml <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
  namespace: default
  annotations:
    alb.ingress.kubernetes.io/load-balancer-name: ${ALB_NAME}
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/security-groups: ${ALB_SECURITY_GROUP_ID}
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/group.name: alb-group
    alb.ingress.kubernetes.io/group.order: "10"
    alb.ingress.kubernetes.io/backend-protocol: HTTP
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}]' # '[{"HTTP": 80}, {"HTTPS": 443}]'
    # alb.ingress.kubernetes.io/ssl-redirect: '443'
    # alb.ingress.kubernetes.io/certificate-arn: 
    # alb.ingress.kubernetes.io/ssl-policy: ELBSecurityPolicy-TLS13-1-2-2021-06
    alb.ingress.kubernetes.io/load-balancer-attributes: |
      load_balancing.cross_zone.enabled=true
    # alb.ingress.kubernetes.io/load-balancer-attributes: |
    #   load_balancing.cross_zone.enabled=true,
    #   routing.http.preserve_host_header.enabled=true,
    #   routing.http.xff_client_port.enabled=true
    #   access_logs.s3.enabled=true,
    #   access_logs.s3.bucket=mzc-test-alarm-s3-elb-log-an2,
    #   access_logs.s3.prefix=mzc-test-alarm-sg-alb-eks-an2,
    # alb.ingress.kubernetes.io/healthcheck-port: '80'
    # alb.ingress.kubernetes.io/healthcheck-path: /
    # alb.ingress.kubernetes.io/healthcheck-interval-seconds: '10'
    # alb.ingress.kubernetes.io/healthcheck-timeout-seconds: '5'
    # alb.ingress.kubernetes.io/healthy-threshold-count: '3'
    # alb.ingress.kubernetes.io/unhealthy-threshold-count: '3'
    # alb.ingress.kubernetes.io/wafv2-acl-arn: <WAF_ACL_ARN>
    # alb.ingress.kubernetes.io/waf-acl-id: <WAF_ACL_ID>
    alb.ingress.kubernetes.io/actions.prefix-rule-200: >
      {"type":"fixed-response","fixedResponseConfig":{"contentType":"text/plain","statusCode":"200","messageBody":"ALB works!"}}
spec:
  ingressClassName: alb
  rules:
  - http:
      paths:
      - path: /
        pathType: ImplementationSpecific
        backend:
          service:
            name: ${SERVICE_NAME}
            port:
              number: 80
EOF

kubectl apply -f tmp/nginx-ingress.yaml