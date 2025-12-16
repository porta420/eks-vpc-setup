
variable "project_name" {
  description = "Project name prefix"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the RDS instance"
  type        = string
}

variable "private_subnets" {
  description = "Private subnets for RDS"
  type        = list(string)
}

variable "db_password" {
  description = "Password for RDS MySQL user"
  type        = string
  sensitive   = true
}
variable "eks_node_sg_id" {
  description = "Security group ID of the EKS worker nodes"
  type        = string
}
variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}