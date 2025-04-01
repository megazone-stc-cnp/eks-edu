#!/bin/bash

# Check if tmp directory exists, if not create it
if [ ! -d "tmp" ]; then
    mkdir -p tmp
fi

cat >tmp/fargate-profile-trust-relationship.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks-fargate-pods.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF