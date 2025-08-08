# read VPC info from remote state
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
  subnet_ids      = data.terraform_remote_state.vpc.outputs.public_subnets  # nodes in public subnets for now

  enable_irsa = true
  enable_cluster_creator_admin_permissions = true

  # make control plane private-only
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = false

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
    terraform_admin = {
      principal_arn = "arn:aws:iam::719136959080:user/terraform"
      policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
      type          = "STANDARD"
    }

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

# allow bastion (bastion_sg) to reach the control plane on 443
resource "aws_security_group_rule" "allow_bastion_to_eks" {
  description              = "Allow bastion SG to access EKS control plane (HTTPS)"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = module.eks.cluster_security_group_id
  source_security_group_id = aws_security_group.bastion_sg.id
}
