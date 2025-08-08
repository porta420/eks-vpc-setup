#!/bin/bash

set -e

echo "Starting installation of Terraform, AWS CLI v2, and kubectl..."

# Update package index and install dependencies
sudo apt-get update -y
sudo apt-get install -y curl unzip gnupg software-properties-common apt-transport-https ca-certificates

# -------- Install Terraform --------

echo "Installing Terraform..."

# Remove old keyring if exists to avoid overwrite prompt
sudo rm -f /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Add HashiCorp GPG key
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Add official HashiCorp Linux repository
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
  sudo tee /etc/apt/sources.list.d/hashicorp.list

# Update and install Terraform
sudo apt-get update -y
sudo apt-get install -y terraform

echo "Terraform version: $(terraform version | head -n1)"

# -------- Install AWS CLI v2 --------

echo "Installing AWS CLI v2..."

# Check if AWS CLI is installed and update if needed
if command -v aws >/dev/null 2>&1; then
  echo "AWS CLI found, updating..."
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
  unzip -q /tmp/awscliv2.zip -d /tmp
  sudo /tmp/aws/install --update
else
  echo "AWS CLI not found, installing..."
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
  unzip -q /tmp/awscliv2.zip -d /tmp
  sudo /tmp/aws/install
fi

aws --version

# Clean up AWS CLI installer files
rm -rf /tmp/aws /tmp/awscliv2.zip

# -------- Install kubectl --------

echo "Installing kubectl..."

# Download latest stable kubectl binary
KUBECTL_VERSION=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)

curl -LO "https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"

sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

kubectl version --client --short

rm kubectl

echo "Installation completed successfully!"