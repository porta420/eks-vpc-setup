#!/bin/bash
# Update package list and upgrade existing packages
apt-get update -y
apt-get upgrade -y

# Install dependencies
apt-get install -y curl unzip apt-transport-https ca-certificates software-properties-common

# Install Terraform
TERRAFORM_VERSION="1.5.7"
curl -LO https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
mv terraform /usr/local/bin/
chmod +x /usr/local/bin/terraform
rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -rf awscliv2.zip aws/

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl

# Verify installations
terraform -version
aws --version
kubectl version --client
