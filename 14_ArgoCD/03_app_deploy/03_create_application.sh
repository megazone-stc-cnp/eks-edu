#!/bin/bash


DEPLOY_NAME=test
NAMESPACE_NAME=default
WEB_URL=http://gitea.cnp.mzcstc.com/hcseo/test.git
ARGOCD_NAMESPACE_NAME=argocd
# ==========================================
if [ ! -d "tmp" ]; then
    mkdir -p tmp
fi

cat >tmp/application.yaml <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ${DEPLOY_NAME}
spec:
  destination:
    namespace: ${NAMESPACE_NAME}
    server: https://kubernetes.default.svc
  source:
    path: ${DEPLOY_NAME}
    repoURL: http://gitea.cnp.mzcstc.com/hcseo/test.git
    targetRevision: HEAD
    helm:
      valueFiles: []
  sources: []
  project: default
  syncPolicy:
    automated:
      prune: false
      selfHeal: false
EOF

echo "kubectl apply -f tmp/application.yaml -n ${ARGOCD_NAMESPACE_NAME}"
echo ""
kubectl apply -f tmp/application.yaml -n ${ARGOCD_NAMESPACE_NAME}