#!/bin/bash
if [ ! -f "../../env.sh" ];then
	echo "env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../env.sh

if [ ! -f "../../vpc_env.sh" ];then
	echo "vpc_env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ../../vpc_env.sh

if [ ! -f "./local_env.sh" ];then
	echo "local_env.sh 파일 세팅을 해주세요."
	exit 1
fi
. ./local_env.sh

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