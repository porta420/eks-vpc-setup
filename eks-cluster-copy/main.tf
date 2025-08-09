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
  ansible_role = {
    principal_arn = "arn:aws:iam::719136959080:role/project022d-eks-eksadmin-role"
    policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
    type          = "STANDARD"
  }
}


  tags = {
    Environment = "dev"
    Project     = "project022d"
  }
}

# Allow inbound HTTPS (port 443) from the default VPC Security Group
# This gives the Terraform/EKS admin server (in same VPC & SG) access to the EKS control plane.
resource "aws_security_group_rule" "allow_https_from_default_sg" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = module.eks.cluster_security_group_id
  source_security_group_id = data.terraform_remote_state.vpc.outputs.default_security_group_id
  description              = "Allow HTTPS access from default VPC SG (EKS admin server)"
}

# Allow NodePort range access (if needed) for testing external services
# WARNING: Currently open to all (0.0.0.0/0). Restrict in production.
resource "aws_security_group_rule" "allow_nodeport_access" {
  type              = "ingress"
  from_port         = 30000
  to_port           = 32767
  protocol          = "tcp"
  security_group_id = module.eks.cluster_security_group_id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow NodePort range access from anywhere (testing only)"
}
