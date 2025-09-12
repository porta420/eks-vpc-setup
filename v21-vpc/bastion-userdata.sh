#!/bin/bash
set -e

# Update system and install dependencies
apt-get update -y
apt-get install -y curl unzip apt-transport-https ca-certificates gnupg software-properties-common tar gzip

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip /tmp/awscliv2.zip -d /tmp
/tmp/aws/install

# Install kubectl (latest stable)
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl

# Install Terraform
TERRAFORM_VERSION="1.5.7"
curl -LO "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
mv terraform /usr/local/bin/
rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Install Helm (latest)
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install eksctl (latest)
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
mv /tmp/eksctl /usr/local/bin

# Verify installs
echo "Installed versions:" >> /tmp/userdata.log
aws --version >> /tmp/userdata.log 2>&1
kubectl version --client >> /tmp/userdata.log 2>&1
terraform version >> /tmp/userdata.log 2>&1
helm version >> /tmp/userdata.log 2>&1
eksctl version >> /tmp/userdata.log 2>&1

echo "Bastion setup complete!" >> /tmp/userdata.log 
# Install Velero CLI
VELERO_VERSION="v1.13.0"
curl -L https://github.com/vmware-tanzu/velero/releases/download/${VELERO_VERSION}/velero-${VELERO_VERSION}-linux-amd64.tar.gz -o /tmp/velero.tar.gz
tar -xvf /tmp/velero.tar.gz -C /tmp
mv /tmp/velero-${VELERO_VERSION}-linux-amd64/velero /usr/local/bin/
velero version --client
