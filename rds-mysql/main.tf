terraform {
  required_version = ">= 1.3.0"
}


provider "aws" {
  region = "eu-north-1"
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = var.vpc_remote_state_bucket
    key    = var.vpc_remote_state_key
    region = var.region
  }
}

resource "aws_db_subnet_group" "default" {
  name       = "mysql-subnet-group"
  subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnets

  tags = {
    Name = "mysql-subnet-group"
  }
}

resource "aws_db_instance" "mysql" {
  identifier         = "${var.db_identifier}"
  engine             = "mysql"
  engine_version     = "8.0"
  instance_class     = "db.t3.micro"
  allocated_storage  = 20
  storage_type       = "gp2"
  username           = var.db_username
  password           = var.db_password
  db_name            = var.db_name
  publicly_accessible = false
  vpc_security_group_ids = [data.terraform_remote_state.vpc.outputs.default_security_group_id]
  db_subnet_group_name   = aws_db_subnet_group.default.name
  skip_final_snapshot    = true

  tags = {
    Environment = "dev"
    Project     = "project022d"
  }
}
