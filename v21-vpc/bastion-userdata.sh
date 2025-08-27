#!/bin/bash
set -e

# Update system and install dependencies
apt-get update -y
apt-get install -y curl unzip apt-transport-https ca-certificates gnupg software-properties-common

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip /tmp/awscliv2.zip -d /tmp
/tmp/aws/install

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl

# Install Terraform
TERRAFORM_VERSION="1.5.7"
curl -LO "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
mv terraform /usr/local/bin/
rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Verify installs
aws --version
kubectl version --client
terraform version

# Ready to clone and run provisioning scripts