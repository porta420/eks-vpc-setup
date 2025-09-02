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
  # Core EKS + EBS CSI driver addons
  addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent   = true
      before_compute = true
    }
    eks-pod-identity-agent = {
      most_recent   = true
      before_compute = true
    }
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = aws_iam_role.ebs_csi_driver.arn
    }
  }

  # ---------------------------------------
# EKS Control Plane Logging (Commented)
# ---------------------------------------
# Enable control plane logging for audit, API, and other components
# cluster_enabled_log_types = [
#   "api",
#   "audit",
#   "authenticator",
#   "controllerManager",
#   "scheduler"
# ]

# Optional: CloudWatch log group with retention
# resource "aws_cloudwatch_log_group" "eks_control_plane" {
#   name              = "/aws/eks/${module.eks.cluster_name}/cluster"
#   retention_in_days = 30  # adjust as needed (e.g., 7, 30, 90)
# }

# Optional: Attach IAM policy to cluster role if custom IAM is used
# resource "aws_iam_role_policy_attachment" "eks_logging" {
#   role       = module.eks.cluster_iam_role_name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
# }


  # Public access only (no NAT → use public subnets)
  endpoint_public_access  = true
  endpoint_private_access = true
  endpoint_public_access_cidrs = ["64.246.65.126/32"] # Example CIDR, replace with your own

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

# Allow bastion SG to talk to EKS nodes
resource "aws_security_group_rule" "allow_bastion_to_nodes" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = data.terraform_remote_state.vpc.outputs.bastion_sg_id
  security_group_id        = module.eks.node_security_group_id
  description              = "Allow bastion SG access to worker nodes"
}

# Allow bastion SG to reach cluster API (if using public/private endpoint)
resource "aws_security_group_rule" "allow_bastion_to_cluster" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = data.terraform_remote_state.vpc.outputs.bastion_sg_id
  security_group_id        = module.eks.cluster_security_group_id
  description              = "Allow bastion SG access to EKS control plane"
}

# IAM Role for EBS CSI Driver
resource "aws_iam_role" "ebs_csi_driver" {
  name = "${var.cluster_name}-ebs-csi-driver-role"

  assume_role_policy = data.aws_iam_policy_document.ebs_csi_assume_role.json
}

data "aws_iam_policy_document" "ebs_csi_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.oidc_provider, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver" {
  role       = aws_iam_role.ebs_csi_driver.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}
