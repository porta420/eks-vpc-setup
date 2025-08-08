terraform {
  required_version = ">= 1.3.0"
}


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
  version = "20.8.5"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"
  vpc_id          = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_ids      = data.terraform_remote_state.vpc.outputs.public_subnets

  enable_irsa = true
  enable_cluster_creator_admin_permissions = true
  cluster_endpoint_public_access           = true

  eks_managed_node_groups = {
    default = {
      desired_size   = 2
      min_size       = 1
      max_size       = 3
      instance_types = ["t3.small"]
      capacity_type  = "ON_DEMAND"
      key_name       = var.key_name
    }
  }

access_entries = {
  # Terraform IAM user - full cluster admin rights via AWS-managed policy
  terraform_admin = {
    principal_arn = "arn:aws:iam::719136959080:user/terraform"
    policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
    type          = "STANDARD"
  }

  # Bastion host IAM role - full cluster admin rights via AWS-managed policy
  bastion_access = {
    principal_arn = "arn:aws:iam::719136959080:role/project022d-eks-bastion-role"
    policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
    type          = "STANDARD"
  }
}


  tags = {
    Environment = "dev"
    Project     = "project022d"
  }
}
