
# -----------------------
# RDS MySQL for WordPress
# -----------------------
terraform {
  required_version = ">= 1.5.7"
}

provider "aws" {
  region = var.region
}

resource "aws_db_subnet_group" "wordpress_db" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.private_subnets

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

# Allow incoming MySQL traffic from EKS worker nodes
resource "aws_security_group" "wordpress_db_sg" {
  name        = "${var.project_name}-db-sg"
  description = "Allow MySQL access from EKS nodes"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.eks_node_sg_id] # allow EKS worker nodes
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-db-sg"
  }
}

resource "aws_db_instance" "wordpress_db" {
  identifier             = "${var.project_name}-db"
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"   # latest stable MySQL
  instance_class         = "db.t3.micro" # free tier/demo friendly
  db_subnet_group_name   = aws_db_subnet_group.wordpress_db.name
  vpc_security_group_ids = [aws_security_group.wordpress_db_sg.id]
  publicly_accessible    = false

  db_name     = "wordpress"
  username = "wpadmin"
  password = var.db_password

  skip_final_snapshot = true

  tags = {
    Name = "${var.project_name}-db"
  }
}

# -----------------------
# Outputs
# -----------------------

output "db_endpoint" {
  description = "RDS endpoint to use in WordPress"
  value       = aws_db_instance.wordpress_db.endpoint
}

output "db_name" {
  value = aws_db_instance.wordpress_db.db_name
}

output "db_username" {
  value = aws_db_instance.wordpress_db.username
}

