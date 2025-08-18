variable "region" {
  default = "eu-north-1"
}

variable "cluster_name" {
  default = "project022d-eks-v21"
}

variable "project_name" {
  default = "project022d"
}

variable "key_name" {
  default = "ansible"
}

variable "vpc_remote_state_bucket" {
  default = "noel-s3-tf-state-bucket"
}

variable "vpc_remote_state_key" {
  default = "vpc/terraform.tfstate"
}
