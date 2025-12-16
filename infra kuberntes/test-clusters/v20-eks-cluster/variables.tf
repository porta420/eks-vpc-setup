variable "cluster_name" {
  type    = string
  default = "project022d-eks"
}

variable "region" {
  type    = string
  default = "eu-north-1"
}

variable "vpc_remote_state_bucket" {
  type    = string
  default = "noel-s3-tf-state-bucket"
}

variable "vpc_remote_state_key" {
  type    = string
  default = "vpc/terraform.tfstate"
}


variable "key_name" {
  description = "EC2 key pair name for SSH access to nodes"
  type        = string
  default     = "ansible" # Update with your key pair name
}
