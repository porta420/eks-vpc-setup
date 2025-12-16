👨‍💻 Author

Noel Kiniben
DevOps Engineer | Cloud Engineer | SRE
LinkedIn: https://www.linkedin.com/in/noel-kiniben-272a56249

Terraform AWS EKS VPC Setup

What This Project Does:

Creates a custom AWS VPC
Provisions public and private subnets across multiple AZs
Configures Internet Gateway and NAT Gateway
Sets up route tables and subnet associations
Outputs required values for integrating with an EKS cluster
Designed as a reusable base for Kubernetes workloads on AWS

Terraform
AWS VPC
Amazon EKS (network foundation)
Infrastructure as Code (IaC)

🧱 Architecture Overview

Public Subnets
Used for load balancers and internet-facing resources
Private Subnets
Intended for EKS worker nodes and internal services
NAT Gateway
Allows outbound internet access for private resources
Multi-AZ Design
Improves availability and fault tolerance


