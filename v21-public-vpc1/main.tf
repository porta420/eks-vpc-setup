terraform {
  required_version = ">= 1.5.7"

  backend "s3" {
    bucket = "noel-s3-tf-state-bucket"
    key    = "vpc-public/terraform.tfstate"
    region = "eu-north-1"
    # dynamodb_table = "YOUR-LOCK-TABLE"
    # encrypt        = true
  }
}

provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = var.project_name
  cidr = var.vpc_cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
  public_subnets  = var.public_subnets
  private_subnets = [] # none (we're going public-only to avoid NAT costs)

  #  NAT OFF to avoid costs
  enable_nat_gateway = false
  single_nat_gateway = false

  #  Ensure instances in public subnets get public IPs
  map_public_ip_on_launch = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  tags = {
    Environment = "dev"
    Project     = var.project_name
  }
}

