# ────────────────────────────────────────────────
# Bastion Host EC2 Instance
# ────────────────────────────────────────────────

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
data "aws_iam_instance_profile" "ansible" {
  name = "ansible"
}

resource "aws_instance" "bastion" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small" # small/cheap instance for bastion

  subnet_id = module.vpc.public_subnets[0] # place in 1st public subnet

  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  associate_public_ip_address = true
  key_name                    = var.key_name
  user_data_base64 = filebase64("${path.module}/bastion-userdata.sh")
  iam_instance_profile = data.aws_iam_instance_profile.ansible.name

  tags = {
    Name    = "${var.project_name}-bastion"
    Project = var.project_name
  }

  depends_on = [module.vpc]
}

output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = aws_instance.bastion.public_ip
}
