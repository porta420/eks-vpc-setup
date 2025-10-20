
terraform {
  required_version = ">= 1.5.7"
}

provider "aws" {
  region = var.region
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.cluster_name
  kubernetes_version = "1.29"

  addons = {
    coredns = { most_recent = true }
    kube-proxy = { most_recent = true }
    vpc-cni = {
      most_recent    = true
      before_compute = true
    }
    eks-pod-identity-agent = {
      most_recent    = true
      before_compute = true
    }
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = aws_iam_role.ebs_csi_driver.arn
    }
  }

  endpoint_public_access        = true
  endpoint_private_access       = true
  endpoint_public_access_cidrs  = ["0.0.0.0/0"] # adjust for demo; restrict in prod

  vpc_id     = var.vpc_id
  subnet_ids = var.public_subnet_ids

  # access_entries = {
  #   admin = {
  #     principal_arn = var.admin_role_arn
  #     policy_associations = {
  #       admin = {
  #         policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
  #         access_scope = {
  #           namespaces = ["default"]
  #           type       = "namespace"
  #         }
  #       }
  #     }
  #   }
  # }

  eks_managed_node_groups = {
    default = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.small"]

      min_size     = 2
      max_size     = 3
      desired_size = 2

      capacity_type = "ON_DEMAND"

      cluster_tags = {
        "k8s.io/cluster-autoscaler/enabled"             = "true"
        "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
      }
    }
  }

  enable_cluster_creator_admin_permissions = true

  tags = {
    Environment = "demo"
    Project     = var.project_name
  }
}

# Allow NodePort access (demo only!)
resource "aws_security_group_rule" "allow_nodeport_access" {
  type              = "ingress"
  from_port         = 30000
  to_port           = 32767
  protocol          = "tcp"
  security_group_id = module.eks.node_security_group_id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow NodePort access (demo)"
}

# Allow bastion host SG → Nodes
resource "aws_security_group_rule" "allow_bastion_to_nodes" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = var.bastion_sg_id
  security_group_id        = module.eks.node_security_group_id
  description              = "Allow bastion → worker nodes"
}

# Allow bastion host SG → Control plane
resource "aws_security_group_rule" "allow_bastion_to_cluster" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = var.bastion_sg_id
  security_group_id        = module.eks.cluster_security_group_id
  description              = "Allow bastion → EKS API"
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
