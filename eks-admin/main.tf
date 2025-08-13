provider "aws" {
  region = var.region
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = var.vpc_remote_state_bucket
    key    = var.vpc_remote_state_key
    region = var.region
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical Ubuntu

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

data "aws_iam_instance_profile" "eksadmin_profile" {
  name = "ansible"
}

resource "aws_instance" "eksadmin" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.small"
  subnet_id                   = element(data.terraform_remote_state.vpc.outputs.public_subnets, 0)
  vpc_security_group_ids      = [data.terraform_remote_state.vpc.outputs.default_security_group_id]
  key_name                   = var.key_name
  iam_instance_profile        = data.aws_iam_instance_profile.eksadmin_profile.name
  associate_public_ip_address = true

  user_data = file("${path.module}/eksadmin_userdata.sh")

  tags = {
    Name        = "${var.cluster_name}-eksadmin"
    Environment = "dev"
    Project     = "project022d"
  }
}
