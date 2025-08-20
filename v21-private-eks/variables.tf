variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "project_name" {
  description = "Project name tag"
  type        = string
  default     = "project022d"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "project022d-eks-v21"
}

# Remote state for the NAT-enabled VPC
variable "vpc_remote_state_bucket" {
  description = "S3 bucket name where VPC state is stored"
  type        = string
  default     = "noel-s3-tf-state-bucket"
}

variable "vpc_remote_state_key" {
  description = "S3 key/path to VPC state (e.g., vpc/terraform.tfstate)"
  type        = string
  default     = "vpc/terraform.tfstate"
}

