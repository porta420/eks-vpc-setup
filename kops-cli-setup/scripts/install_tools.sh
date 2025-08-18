#!/usr/bin/env bash
set -euo pipefail

if [ "$EUID" -ne 0 ]; then
  echo "Please run with sudo: sudo bash $0"; exit 1
fi

OS=$(uname | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
[ "$ARCH" = "x86_64" ] && ARCH=amd64

# kubectl (stable)
curl -L -o /usr/local/bin/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/${OS}/${ARCH}/kubectl"
chmod +x /usr/local/bin/kubectl

# terraform (pin a recent, stable)
TF_VERSION=1.8.5
curl -L -o /tmp/terraform.zip https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_${OS}_${ARCH}.zip
unzip -o /tmp/terraform.zip -d /usr/local/bin

# kops
KOPS_VERSION=1.32.0
curl -L -o /usr/local/bin/kops https://github.com/kubernetes/kops/releases/download/v${KOPS_VERSION}/kops-${OS}-${ARCH}
chmod +x /usr/local/bin/kops

# helm
HELM_VERSION=3.15.3
curl -L https://get.helm.sh/helm-v${HELM_VERSION}-${OS}-${ARCH}.tar.gz | tar zx
mv ${OS}-${ARCH}/helm /usr/local/bin/helm
chmod +x /usr/local/bin/helm

echo "Installed: kubectl, terraform, kops, helm"