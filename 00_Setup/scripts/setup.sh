#!/bin/bash

set -e

if [[ ! -d "~/.bashrc.d" ]]; then
  mkdir -p ~/.bashrc.d
  
  touch ~/.bashrc.d/dummy.bash

  echo 'for file in ~/.bashrc.d/*.bash; do source "$file"; done' >> ~/.bashrc
fi


# AWS CLI 환경변수 설정
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
cat << EOT > ~/.bashrc.d/aws.bash
export AWS_PAGER="jq"
export AWS_REGION="${AWS_REGION}"
export AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID}"
EOT

# Bash completions
LOCAL_BASH_COMPLETION_DIR=~/.local/share/bash-completion/completions
mkdir -p $LOCAL_BASH_COMPLETION_DIR
/usr/local/bin/kubectl completion bash > $LOCAL_BASH_COMPLETION_DIR/kubectl
/usr/local/bin/helm completion bash > $LOCAL_BASH_COMPLETION_DIR/helm
/usr/local/bin/kind completion bash > $LOCAL_BASH_COMPLETION_DIR/kind
/usr/local/bin/eksctl completion bash > $LOCAL_BASH_COMPLETION_DIR/eksctl
/usr/local/bin/yq completion bash > $LOCAL_BASH_COMPLETION_DIR/yq
/usr/local/bin/argocd completion bash > $LOCAL_BASH_COMPLETION_DIR/argocd
/usr/bin/docker completion bash > $LOCAL_BASH_COMPLETION_DIR/docker

# bashrc
cat << EOT > ~/.bashrc.d/kubectl.bash
# source <(kubectl completion bash)
alias kubectl=kubecolor
alias k=kubectl
# Make "kubecolor" borrow the same completion logic as "kubectl"
complete -o default -F __start_kubectl kubecolor
# Make "k" borrow the same completion logic as "kubectl"
complete -o default -F __start_kubectl k
EOT

echo "eval \"\$(fzf --bash)\"" > ~/.bashrc.d/fzf.bash

echo "complete -C /usr/local/bin/terraform terraform" > ~/.bashrc.d/terraform.bash

cat << EOT > ~/.bashrc.d/krew.bash
if ! [[ "\$PATH" =~ "\$HOME/.krew/bin:" ]]
then
    PATH="\$HOME/.krew/bin:\$PATH"
fi
export PATH
EOT


# Aliases for 'ls'
cat << EOT > ~/.bashrc.d/aliases.bash
# List directories first
alias ls='ls -F --color=auto --group-directories-first'
alias ll='ls -al'
alias l='ll'
EOT