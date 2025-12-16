output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "default_security_group_id" {
  value = module.vpc.default_security_group_id
}
output "bastion_sg_id" {
  value       = aws_security_group.bastion_sg.id
  description = "Security group ID for bastion/admin access"
}
