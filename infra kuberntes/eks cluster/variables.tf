variable "region" {
  description = "AWS region"
  default     = "eu-north-1"
}

variable "project_name" {
  description = "Project name"
  default     = "project022d"
}

variable "cluster_name" {
  description = "EKS Cluster name"
  default     = "project022d-eks-v21"
}

variable "vpc_remote_state_bucket" {
  description = "S3 bucket name for VPC state"
  default     = "noel-s3-tf-state-bucket"
}

variable "vpc_remote_state_key" {
  description = "Path to VPC state file in S3"
  default     = "vpc/terraform.tfstate"
}

variable "velero_backup_bucket" {
  description = "S3 bucket name where Velero stores backups"
  type        = string
  default     = "noel-s3-tf-state-bucket" # change if needed
}

variable "velero_region" {
  description = "AWS region for Velero backup storage"
  type        = string
  default     = "eu-north-1"
}
