#!/bin/bash

cat >tmp/custom_values.yaml <<EOF
global:
  security:
    allowInsecureImages: true
image:
  registry: public.ecr.aws
  repository: bitnami/nginx
  tag: 1.28.0-debian-12-r3
EOF

