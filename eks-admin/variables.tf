variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "project022d-eks"
}

variable "key_name" {
  description = "Name of the SSH key pair for EC2 access"
  type        = string
  default     = "ansible"
}

variable "vpc_remote_state_bucket" {
  description = "S3 bucket name for remote state of VPC"
  type        = string
  default     = "noel-s3-tf-state-bucket"
}

variable "vpc_remote_state_key" {
  type    = string
  default = "vpc/terraform.tfstate"
}