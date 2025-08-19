terraform {
  required_version = ">= 1.5.7"

  backend "s3" {
    bucket = "noel-s3-tf-state-bucket"
    key    = "eks-public/terraform.tfstate"
    region = "eu-north-1"
  }
}

provider "aws" {
  region = var.region
}

# Read VPC state (public subnets only)
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = var.vpc_remote_state_bucket
    key    = var.vpc_remote_state_key
    region = var.region
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.cluster_name
  kubernetes_version = "1.29"

  # Core EKS addons 
  addons = {
    coredns                = {}
    kube-proxy             = {}
    vpc-cni                = { before_compute = true }
    eks-pod-identity-agent = { before_compute = true }
  }

  # Public access only (no NAT → use public subnets)
  endpoint_public_access  = true
  endpoint_private_access = false
  endpoint_public_access_cidrs = ["10.50.0.0/16","64.246.65.126"]

  vpc_id     = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.vpc.outputs.public_subnets
  
  access_entries = {
    # One access entry with a policy associated
    admin = {
      principal_arn = "arn:aws:iam::719136959080:role/kubernetes"

      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
          access_scope = {
            namespaces = ["default"]
            type       = "namespace"
          }
        }
      }
    }
  }

  # Node group
  eks_managed_node_groups = {
    default = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.small"]

      min_size     = 2
      max_size     = 4
      desired_size = 2

      capacity_type = "ON_DEMAND"
    }
  }

  enable_cluster_creator_admin_permissions = true

  tags = {
    Environment = "dev"
    Project     = var.project_name
  }
}

# (Optional) Security group rule to allow NodePort access (testing only)
resource "aws_security_group_rule" "allow_nodeport_access" {
  type              = "ingress"
  from_port         = 30000
  to_port           = 32767
  protocol          = "tcp"
  security_group_id = module.eks.node_security_group_id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow NodePort access from anywhere"
}
