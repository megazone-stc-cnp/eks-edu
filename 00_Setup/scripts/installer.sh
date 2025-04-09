#!/bin/bash

set -e

# docker-compose
docker_compose_version='2.34.0'                 # unknown

# kind
kind_version='0.27.0'                           # 2025-02-15

# renovate: depName=kubernetes/kubernetes
kubectl_version='1.31.6'                        # 2025-02-11

# renovate: depName=helm/helm
helm_version='3.17.2'                           # 2025-03-14

# renovate: depName=eksctl-io/eksctl
eksctl_version='0.206.0'                        # 2025-03-23

# renovate: depName=bitnami-labs/sealed-secrets
kubeseal_version='0.28.0'                       # 2025-01-16

# renovate: depName=krew
krew_version='0.5.1'                            # 2025-03-25

# renovate: depName=mikefarah/yq
yq_version='4.45.1'                             # 2025-01-12

# renovate: depName=argoproj/argo-cd
argocd_version='2.14.8'                         # 2025-03-25

# renovate: depName=hashicorp/terraform
terraform_version='1.11.2'                      # 2025-03-12

# fzf
fzf_version='0.60.3'                            # 2025-03-03

download () {
  url=$1
  out_file=$2

  curl --location --show-error --silent --output $out_file $url
}

download_and_verify () {
  url=$1
  checksum=$2
  out_file=$3

  curl --location --show-error --silent --output $out_file $url

  echo "$checksum $out_file" > "$out_file.sha256"
  sha256sum --check "$out_file.sha256"

  rm "$out_file.sha256"
}

os="$(uname | tr '[:upper:]' '[:lower:]')"
arch=$(uname -m)
arch_name=""

# Convert to amd64 or arm64
case "$arch" in
  x86_64)
    arch_name="amd64"
    ;;
  aarch64)
    arch_name="arm64"
    ;;
  *)
    echo "Unsupported architecture: $arch"
    exit 1
    ;;
esac

yum install --quiet -y findutils jq tar gzip zsh git diffutils wget \
  tree unzip openssl gettext bash-completion python3 python3-pip \
  nc yum-utils docker

pip3 install -q awscurl==0.28 urllib3==1.26.6

# docker
usermod -a -G docker ec2-user
# systemctl enable --now docker
service docker start # == systemctl start docker

# docker-compose
DOCKER_CLI_PLUGINS_PATH="/usr/local/lib/docker/cli-plugins"
download "https://github.com/docker/compose/releases/download/v${docker_compose_version}/docker-compose-linux-${arch}" "docker-compose"
chmod +x ./docker-compose
mkdir -p $DOCKER_CLI_PLUGINS_PATH
mv ./docker-compose $DOCKER_CLI_PLUGINS_PATH

# kind
download "https://kind.sigs.k8s.io/dl/v${kind_version}/kind-linux-${arch_name}" "kind"
chmod +x ./kind
mv ./kind /usr/local/bin/kind

# kubectl
download "https://dl.k8s.io/release/v${kubectl_version}/bin/linux/${arch_name}/kubectl" "kubectl"
chmod +x ./kubectl
mv ./kubectl /usr/local/bin

# helm
download "https://get.helm.sh/helm-v$helm_version-linux-${arch_name}.tar.gz" "helm.tar.gz"
tar zxf helm.tar.gz
chmod +x linux-${arch_name}/helm
mv ./linux-${arch_name}/helm /usr/local/bin
rm -rf linux-${arch_name}/ helm.tar.gz

# eksctl
download "https://github.com/eksctl-io/eksctl/releases/download/v${eksctl_version}/eksctl_Linux_${arch_name}.tar.gz" "eksctl.tar.gz"
tar zxf eksctl.tar.gz
chmod +x eksctl
mv ./eksctl /usr/local/bin
rm -rf eksctl.tar.gz

# aws cli v2
curl --location --show-error --silent "https://awscli.amazonaws.com/awscli-exe-linux-${arch}.zip" -o "awscliv2.zip"
unzip -o -q awscliv2.zip -d /tmp
/tmp/aws/install --update
rm -rf /tmp/aws awscliv2.zip

# kubeseal
download "https://github.com/bitnami-labs/sealed-secrets/releases/download/v${kubeseal_version}/kubeseal-${kubeseal_version}-linux-${arch_name}.tar.gz" "kubeseal.tar.gz"
tar xfz kubeseal.tar.gz
chmod +x kubeseal
mv ./kubeseal /usr/local/bin
rm -rf kubeseal.tar.gz

# krew
KREW_INSTALL_ROOT=/tmp/krew-install
download "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew-linux_${arch_name}.tar.gz" "krew.tar.gz"
mkdir -p /tmp/krew-install
mv krew.tar.gz $KREW_INSTALL_ROOT && cd $KREW_INSTALL_ROOT
tar zxvf "krew.tar.gz"
sudo -u ec2-user $KREW_INSTALL_ROOT/krew-linux_${arch_name} install krew

# yq
download "https://github.com/mikefarah/yq/releases/download/v${yq_version}/yq_linux_${arch_name}" "yq"
chmod +x ./yq
mv ./yq /usr/local/bin

# terraform
download "https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_linux_${arch_name}.zip" "terraform.zip"
unzip -o -q terraform.zip -d /tmp
chmod +x /tmp/terraform
mv /tmp/terraform /usr/local/bin
rm -f terraform.zip

# argocd-cli
download "https://github.com/argoproj/argo-cd/releases/download/v${argocd_version}/argocd-linux-${arch_name}" "argocd"
chmod +x ./argocd
mv ./argocd /usr/local/bin/argocd

# fzf
download "https://github.com/junegunn/fzf/releases/download/v${fzf_version}/fzf-${fzf_version}-linux_${arch_name}.tar.gz" "fzf-${fzf_version}-linux_${arch_name}.tar.gz"
tar xfz fzf-${fzf_version}-linux_${arch_name}.tar.gz
chmod +x fzf
mv ./fzf /usr/local/bin
rm -rf fzf-${fzf_version}-linux_${arch_name}.tar.gz