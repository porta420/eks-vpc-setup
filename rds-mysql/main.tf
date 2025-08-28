# ─────────────────────────────────────────────────────────────
# Remote states
# ─────────────────────────────────────────────────────────────
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = var.vpc_remote_state_bucket
    key    = var.vpc_remote_state_key
    region = var.region
  }
}

data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = var.eks_remote_state_bucket
    key    = var.eks_remote_state_key
    region = var.region
  }
}

# Select subnets based on desired placement
locals {
  db_subnet_ids = (
    var.use_private_subnets
    ? data.terraform_remote_state.vpc.outputs.private_subnets
    : data.terraform_remote_state.vpc.outputs.public_subnets
  )
}


# ─────────────────────────────────────────────────────────────
# Security Group for RDS
# ─────────────────────────────────────────────────────────────
resource "aws_security_group" "rds_sg" {
  name        = "${var.project_name}-rds-sg"
  description = "Allow MySQL access to RDS from EKS and optional CIDRs"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  # default egress
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-rds-sg"
    Project = var.project_name
  }
}

# Allow from EKS nodes SG (exported by your EKS stack as node_security_group_id)
resource "aws_security_group_rule" "mysql_from_eks_nodes" {
  type                     = "ingress"
  security_group_id        = aws_security_group.rds_sg.id
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = data.terraform_remote_state.eks.outputs.node_security_group_id
  description              = "MySQL from EKS node group"
}

# Optional: allow from extra CIDRs (e.g., your workstation)
resource "aws_security_group_rule" "mysql_from_cidrs" {
  count                   = length(var.extra_db_ingress_cidrs) > 0 ? 1 : 0
  type                    = "ingress"
  security_group_id       = aws_security_group.rds_sg.id
  from_port               = 3306
  to_port                 = 3306
  protocol                = "tcp"
  cidr_blocks             = var.extra_db_ingress_cidrs
  description             = "MySQL from extra CIDRs (testing)"
}

# ─────────────────────────────────────────────────────────────
# DB Subnet Group
# ─────────────────────────────────────────────────────────────
resource "aws_db_subnet_group" "rds_subnets" {
  name       = "${var.project_name}-rds-subnet-group"
  subnet_ids = local.db_subnet_ids

  tags = {
    Name    = "${var.project_name}-rds-subnet-group"
    Project = var.project_name
  }
}

# ─────────────────────────────────────────────────────────────
# RDS MySQL Instance
# ─────────────────────────────────────────────────────────────
resource "aws_db_instance" "mysql" {
  identifier        = "${var.project_name}-mysql"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.rds_subnets.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  # Placement/Exposure
  publicly_accessible = var.publicly_accessible
  multi_az            = var.multi_az

  # Backups/maintenance (tune for prod as needed)
  backup_retention_period = 1
  deletion_protection     = false
  skip_final_snapshot     = true

  # Storage type defaults to gp2; upgrade if needed:
  storage_type   = "gp3"
  max_allocated_storage = 100

  # Performance insights (optional)
  performance_insights_enabled = false

  tags = {
    Name    = "${var.project_name}-mysql"
    Project = var.project_name
  }
}
