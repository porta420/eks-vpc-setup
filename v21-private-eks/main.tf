
# ─────────────────────────────────────────────────────────────
# Read VPC outputs (this VPC must have: NAT enabled, IGW, DNS)
# ─────────────────────────────────────────────────────────────
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = var.vpc_remote_state_bucket
    key    = var.vpc_remote_state_key      # e.g. "vpc/terraform.tfstate"
    region = var.region
  }
}

# ─────────────────────────────────────────────────────────────
# EKS (v21.x) – private API endpoint, nodes in private subnets
# ─────────────────────────────────────────────────────────────
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.cluster_name
  kubernetes_version = "1.29"

  # Networking
  vpc_id                   = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_ids               = data.terraform_remote_state.vpc.outputs.private_subnets
  control_plane_subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnets

  # Endpoint: PRIVATE ONLY
  endpoint_private_access = true
  endpoint_public_access  = false

  # Security & auth
  enable_irsa                              = true
  enable_cluster_creator_admin_permissions  = true
  #cluster_enabled_log_types                 = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # Core add-ons
  addons = {
    coredns                = {}
    kube-proxy             = {}
    vpc-cni                = { before_compute = true }
    eks-pod-identity-agent = { before_compute = true }
  }

  # Managed node group(s) – private subnets
  eks_managed_node_groups = {
    default = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.medium"]

      min_size     = 2
      desired_size = 2
      max_size     = 4

      capacity_type = "ON_DEMAND"
      disk_size     = 50
      labels        = { role = "general" }
    }
  }

  tags = {
    Environment = "prod"
    Project     = var.project_name
  }
}
