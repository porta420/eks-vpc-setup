variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "demo-eks"
}

variable "project_name" {
  description = "Project tag"
  type        = string
  default     = "eks-demo"
}

variable "vpc_id" {
  description = "VPC ID where EKS will be deployed"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "bastion_sg_id" {
  description = "Bastion host security group ID"
  type        = string
}

# variable "admin_role_arn" {
#   description = "IAM role ARN for EKS admin access"
#   type        = string
# }

