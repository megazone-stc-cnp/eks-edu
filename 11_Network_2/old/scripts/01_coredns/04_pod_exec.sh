#!/bin/bash

echo "kubectl run test-pod --image=busybox --restart=Never --rm -it -- /bin/sh "
echo "terminal에서 아래와 같이 조회하세요"
echo "# nslookup myapp.local"
kubectl run test-pod --image=busybox --restart=Never --rm -it -- /bin/sh

