terraform {
  required_version = ">= 1.5.7"

  backend "s3" {
    bucket = "noel-s3-tf-state-bucket"
    key    = "eks-public/terraform.tfstate"
    region = "eu-north-1"
    # dynamodb_table = "YOUR-LOCK-TABLE"
    # encrypt        = true
  }
}

provider "aws" {
  region = var.region
}

# --- NOT NEEDED if using default VPC ---
# data "terraform_remote_state" "vpc" {
#   backend = "s3"
#   config = {
#     bucket = var.vpc_remote_state_bucket
#     key    = var.vpc_remote_state_key
#     region = var.region
#   }
# }

# --- Node IAM role (standard policies) ---
resource "aws_iam_role" "eks_node_role" {
  name = "${var.cluster_name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "worker_node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}
resource "aws_iam_role_policy_attachment" "worker_node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}
resource "aws_iam_role_policy_attachment" "worker_node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}

# --- EKS module (v21) with PUBLIC endpoint & PUBLIC subnets ---
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.0.5"

  name               = var.cluster_name
  kubernetes_version = "1.29"

  # Replace with your default VPC ID
  vpc_id = "vpc-03e42aeeeb4fbe0ae" 

  # Replace with your actual subnet IDs (public & private as needed)
  subnet_ids = [
    "subnet-0dfbbcaa92b384a3e", # public subnet 1
    "subnet-0522d7328c1c14214", # public subnet 2
  ]

  enable_irsa                             = true
  enable_cluster_creator_admin_permissions = true

  endpoint_private_access = false
  endpoint_public_access  = true

  eks_managed_node_groups = {
    default = {
      desired_size   = 2
      min_size       = 1
      max_size       = 3
      instance_types = ["t3.small"]
      capacity_type  = "ON_DEMAND"
      key_name       = var.key_name

      iam_role_arn = aws_iam_role.eks_node_role.arn

      # ✅ Nodes will use the same subnets you define above
      subnets = [
        "subnet-0dfbbcaa92b384a3e", # public subnet 1
        "subnet-0522d7328c1c14214", # public subnet 2
      ]
    }
  }

  tags = {
    Environment = "dev"
    Project     = var.project_name
  }
}

# Optional: open NodePort range (testing)
resource "aws_security_group_rule" "allow_nodeport_access" {
  type              = "ingress"
  from_port         = 30000
  to_port           = 32767
  protocol          = "tcp"
  security_group_id = module.eks.node_security_group_id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow NodePort range access from anywhere (testing only)"
}
